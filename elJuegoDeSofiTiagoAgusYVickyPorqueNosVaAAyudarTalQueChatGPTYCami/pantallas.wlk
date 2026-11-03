object personaje {
  var property position = game.origin()

  method image() = "muppet.gif"
}

// Una pantalla es una imagen que tapa el juego y que se muestra / se saca.
class Pantalla {
  const property position = game.origin()
  const imagen

  method image() = imagen

  method mostrar() { game.addVisual(self) }
  method ocultar() { game.removeVisual(self) }
  method estaMostrandose() = game.hasVisual(self)
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
// Mientras se muestra es la fase actual del juego, asi que le llegan las teclas F y G.
class PantallaQueEsperaTecla inherits Pantalla {
  var alTerminar = {}

  method mostrar(unBloque) {
    alTerminar = unBloque
    self.mostrar()
  }

  method elegirIzquierda() { self.cerrar() }
  method elegirDerecha() { self.cerrar() }

  method cerrar() {
    if (self.estaMostrandose()) {
      self.ocultar()
      alTerminar.apply()
    }
  }
}

object menu inherits Pantalla(imagen = "menu.png") {}

object instructivo inherits PantallaQueEsperaTecla(imagen = "instructivo.png") {}

object avisoDeExamen inherits PantallaTemporal(imagen = "avisoDeExamen.png", duracion = 4000) {}

// Lo que se ve unos segundos al terminar el examen, antes de volver al menu
object pantallaAprobaste inherits PantallaTemporal(imagen = "aprobaste.png", duracion = 3500) {}

object pantallaDesaprobaste inherits PantallaTemporal(imagen = "desaprobaste.png", duracion = 3500) {}
