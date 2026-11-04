import wollok.game.*

// Pone / saca varias cosas de la pantalla sin romperse si ya estaban (o si no estaban)
object visuales {
  method mostrar(unosVisuales) {
    unosVisuales.forEach({ unVisual => if (not game.hasVisual(unVisual)) game.addVisual(unVisual) })
  }

  method ocultar(unosVisuales) {
    unosVisuales.forEach({ unVisual => if (game.hasVisual(unVisual)) game.removeVisual(unVisual) })
  }
}

object personaje {
  var property position = game.origin()

  method image() = "muppet.gif"
}

// Una pantalla es una imagen que tapa el juego y que se muestra / se saca.
// Mientras se muestra puede ser la fase actual del juego; por defecto ignora F y G.
class Pantalla {
  const property position = game.origin()
  const imagen

  method image() = imagen

  method mostrar() { game.addVisual(self) }
  method ocultar() { game.removeVisual(self) }
  method estaMostrandose() = game.hasVisual(self)

  method elegirIzquierda() {}
  method elegirDerecha() {}
}

// Una pantalla que se saca sola despues de un rato y avisa que termino.
class PantallaTemporal inherits Pantalla {
  const duracion

  method mostrar(alTerminar) {
    self.mostrar()
    game.schedule(duracion, { self.cerrar(alTerminar) })
  }

  method cerrar(alTerminar) {
    self.ocultar()
    alTerminar.apply()
  }
}

// Una pantalla que se queda hasta que apretes F o G, y ahi avisa que termino.
class PantallaQueEsperaTecla inherits Pantalla {
  var alTerminar = {}

  method mostrar(unBloque) {
    alTerminar = unBloque
    self.mostrar()
  }

  override method elegirIzquierda() { self.cerrar() }
  override method elegirDerecha() { self.cerrar() }

  method cerrar() {
    if (self.estaMostrandose()) {
      self.ocultar()
      alTerminar.apply()
    }
  }
}

const menu = new Pantalla(imagen = "menu.png")

const instructivo = new PantallaQueEsperaTecla(imagen = "instructivo.png")

const avisoDeExamen = new PantallaTemporal(imagen = "avisoDeExamen.png", duracion = 4000)

// Lo que se ve unos segundos al terminar el examen, antes de volver al menu
const pantallaAprobaste = new PantallaTemporal(imagen = "aprobaste.png", duracion = 3500)

const pantallaDesaprobaste = new PantallaTemporal(imagen = "desaprobaste.png", duracion = 3500)

// Cartelito de tiza que aparece cuando ya podes pasar a la proxima ronda
object pistaSeguir {
  const property position = game.at(9.25, 1.75)

  method image() = "seguir.png"
}
