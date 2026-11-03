import wollok.game.*

object examen {
  const property position = game.at(26, 0.4)
  var vida = 100

  method derrotado() = vida == 0
  method recibirDanio(puntos) { vida = (vida - puntos).max(0) }
  method reiniciar() { vida = 100 }

  // Examen4 = vida llena ... Examen0 = derrotado (solo cuando la vida llega a 0)
  method image() = "examen/Examen" + (vida / 25).roundUp() + ".gif"
}
