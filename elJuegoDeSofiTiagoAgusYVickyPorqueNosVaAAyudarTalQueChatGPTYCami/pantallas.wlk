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

object menu inherits Pantalla(imagen = "menu.png") {}

object instructivo inherits PantallaTemporal(imagen = "instructivo.png", duracion = 12000) {}

object avisoDeExamen inherits PantallaTemporal(imagen = "avisoDeExamen.png", duracion = 4000) {}
