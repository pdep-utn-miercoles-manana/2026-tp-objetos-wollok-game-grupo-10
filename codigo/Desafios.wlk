import wollok.game.*
import pantallas.*
import Modos.*
import Combate.*

// El texto que se ve sobre una nota (rosa = F, amarilla = G)
class Cartel {
  const imagen
  const nota

  method image() = imagen
  method position() = nota.posicionDelTexto()
}

class Desafio {
  method carteles()
  method danio()

  method apretoF() {}
  method apretoG() {}

  method mostrar() { visuales.mostrar(self.carteles()) }
  method ocultar() { visuales.ocultar(self.carteles()) }

  method acertar() { batalla.acierto(self.danio()) }
  method errar() { batalla.error() }
}

class Pregunta inherits Desafio {
  const nombre
  const correctaEsF
  const izquierda = new Cartel(imagen = "batalla/" + nombre + "_F.png", nota = nota_rosa)
  const derecha = new Cartel(imagen = "batalla/" + nombre + "_G.png", nota = nota_amarilla)

  override method carteles() = [izquierda, derecha]
  override method danio() = 20

  override method apretoF() { self.responder(correctaEsF) }
  override method apretoG() { self.responder(not correctaEsF) }

  method responder(acerto) {
    if (acerto) { self.acertar() } else { self.errar() }
  }
}

class Rafaga inherits Desafio {
  const nombre
  const toques
  const cartel = new Cartel(imagen = "batalla/" + nombre + ".png", nota = nota_rosa)
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
