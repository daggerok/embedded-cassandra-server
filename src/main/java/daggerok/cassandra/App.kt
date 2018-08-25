package daggerok.cassandra

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
  runApplication<App>(*args) {
    setRegisterShutdownHook(true)
  }
}
