package com.ubirch.template.server.route

import com.typesafe.scalalogging.slf4j.StrictLogging

import com.ubirch.template.config.Config
import com.ubirch.template.core.actor.{ActorNames, DeepCheckActor}
import com.ubirch.template.util.server.RouteConstants
import com.ubirch.util.deepCheck.model.{DeepCheckRequest, DeepCheckResponse}
import com.ubirch.util.http.response.ResponseUtil
import com.ubirch.util.rest.akka.directives.CORSDirective

import akka.actor.ActorSystem
import akka.http.scaladsl.model.StatusCodes
import akka.http.scaladsl.server.Route
import akka.pattern.ask
import akka.util.Timeout
import de.heikoseeberger.akkahttpjson4s.Json4sSupport._

import scala.concurrent.ExecutionContextExecutor
import scala.concurrent.duration._
import scala.language.postfixOps
import scala.util.{Failure, Success}

/**
  * author: cvandrei
  * since: 2017-06-07
  */
trait DeepCheckRoute extends CORSDirective
  with ResponseUtil
  with StrictLogging {

  implicit val system = ActorSystem()
  implicit val executionContext: ExecutionContextExecutor = system.dispatcher
  implicit val timeout = Timeout(Config.actorTimeout seconds)

  private val deepCheckActor = system.actorOf(DeepCheckActor.props(), ActorNames.DEEP_CHECK)

  val route: Route = {

    path(RouteConstants.deepCheck) {
      respondWithCORS {

        get {
          onComplete(deepCheckActor ? DeepCheckRequest()) {

            case Failure(t) =>
              logger.error("failed to run deepCheck (check DeepCheckRoute for bugs!!!)", t)
              complete(serverErrorResponse(errorType = "ServerError", errorMessage = "sorry, something went wrong on our end"))

            case Success(resp) =>
              resp match {

                case res: DeepCheckResponse if res.status => complete(res)
                case res: DeepCheckResponse if !res.status => complete(response(responseObject = res, status = StatusCodes.ServiceUnavailable))
                case _ => complete(serverErrorResponse(errorType = "ServerError", errorMessage = "failed to run deep check"))

              }

          }
        }

      }
    }

  }

}