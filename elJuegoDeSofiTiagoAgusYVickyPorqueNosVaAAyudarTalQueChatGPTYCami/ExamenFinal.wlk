object examen {
  const property position = game.at(26, 0)
  var vida = 100

  method derrotado() = vida == 0
  method recibirDanio(puntos) { vida = (vida - puntos).max(0) }
  method reiniciar() { vida = 100 }

  method image() = "examen/Examen" + (vida.div(25)) + ".png"
}
