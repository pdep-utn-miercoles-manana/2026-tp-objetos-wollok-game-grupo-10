import wollok.game.*

// Las teclas F y G que se ven abajo de las notas
class Tecla {
  const letra
  const property position

  method image() = "teclas/tecla_" + letra + ".gif"
}

const botonF = new Tecla(letra = "F", position = game.at(6, 1))
const botonG = new Tecla(letra = "G", position = game.at(18, 1))
