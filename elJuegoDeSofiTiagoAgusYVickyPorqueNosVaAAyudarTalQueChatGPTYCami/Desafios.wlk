import Combate.*

// El texto que se ve sobre una nota (rosa = F, amarilla = G)
class Cartel {
  const imagen
  const nota

  method image() = imagen
  method position() = nota.posicionDelTexto()
}

class Desafio {
  method carteles() = []
  method danio() = 0

  method apretoF() {}
  method apretoG() {}

  method mostrar() { self.carteles().forEach({ unCartel => game.addVisual(unCartel) }) }
  method ocultar() {
    self.carteles().forEach({ unCartel => if (game.hasVisual(unCartel)) { game.removeVisual(unCartel) } })
  }

  method acertar() { batalla.acierto(self.danio()) }
  method errar() { batalla.error() }
}

// Dos respuestas: una en F y otra en G. Hay que elegir la correcta.
class Pregunta inherits Desafio {
  const izquierda
  const derecha
  const correctaEsF

  override method carteles() = [izquierda, derecha]
  override method danio() = 20

  override method apretoF() { self.responder(correctaEsF) }
  override method apretoG() { self.responder(not correctaEsF) }

  method responder(acerto) {
    if (acerto) { self.acertar() } else { self.errar() }
  }
}

// Hay que apretar F muchas veces seguidas.
class Rafaga inherits Desafio {
  const cartel
  const toques
  var cuenta = 0

  override method carteles() = [cartel]
  override method danio() = 30

  override method mostrar() {
    cuenta = 0
    super()
  }

  override method apretoF() {
    cuenta += 1
    if (cuenta >= toques) {
      self.acertar()
    } else {
      game.say(cartel, cuenta.toString() + " / " + toques.toString())
    }
  }
}
