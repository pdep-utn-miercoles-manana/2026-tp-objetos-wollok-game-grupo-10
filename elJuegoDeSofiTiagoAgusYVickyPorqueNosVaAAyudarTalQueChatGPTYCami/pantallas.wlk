object personaje {
  var property position = game.origin()

  method image() = "muppet.gif"
}

// Una pantalla es una imagen que tapa el juego y que se muestra / se saca.
// El menu y el instructivo se comportan igual, por eso comparten esta clase
// y la logica de mostrar/ocultar vive en un solo lugar.
class Pantalla {
  const property position = game.origin()
  const imagen

  method image() = imagen

  method mostrar() { game.addVisual(self) }
  method ocultar() { game.removeVisual(self) }
  method estaMostrandose() = game.hasVisual(self)
}

object menu inherits Pantalla(imagen = "menuTrucho.png", position = game.at(0, -2)) {} // antes estaba en menu.wlk

object instructivo inherits Pantalla(imagen = "instructivo.png") {
  const tiempoDeLectura = 12000

  // lo muestra y, pasado el tiempo de lectura, lo saca y avisa que termino
  method mostrar(alTerminar) {
    self.mostrar()
    game.schedule(tiempoDeLectura, { self.cerrar(alTerminar) })
  }

  method cerrar(alTerminar) {
    self.ocultar()
    alTerminar.apply()
  }
}
