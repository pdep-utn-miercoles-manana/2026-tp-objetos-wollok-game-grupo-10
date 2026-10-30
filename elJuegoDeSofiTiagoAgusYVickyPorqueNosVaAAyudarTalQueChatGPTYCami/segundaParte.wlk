import Caminos.*
import BarraAcad.*
import pantallas.*

object examen {
  const property position = game.at(26, 0)
  var vida = 100

  method derrotado() = vida == 0
  method recibirDanio(puntos) { vida = (vida - puntos).max(0) }
  method reiniciar() { vida = 100 }

  method image() = "examen/Examen" + (vida.div(25)) + ".png" 
}


object avisoDeExamen inherits Pantalla(imagen = "avisoDeExamen.png") {
  method mostrar(alTerminar) {
    self.mostrar()
    game.schedule(4000, { self.cerrar(alTerminar) })
  }

  method cerrar(alTerminar) {
    self.ocultar()
    alTerminar.apply()
  }
}

class Cartel {
  const imagen
  const nota

  method image() = imagen
  method position() = nota.posicionDelTexto()
}


class Desafio {
  method carteles() = []   // los textos que muestra
  method danio() = 0       // cuanta vida le saca al examen si lo resolves

  method apretoF() {}      // cada tipo de desafio decide que hace con F y con G
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
  const izquierda     // cartel de la nota rosa (F)
  const derecha       // cartel de la nota amarilla (G)
  const correctaEsF

  override method carteles() = [izquierda, derecha]
  override method danio() = 20

  override method apretoF() { self.responder(correctaEsF) }
  override method apretoG() { self.responder(not correctaEsF) }

  method responder(acerto) {
    if (acerto) { self.acertar() } else { self.errar() }
  }
}

// Hay que apretar F muchas veces seguidas. Pega mas fuerte que una pregunta.
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

// ---------------------------------------------------------------------------
// LA BATALLA
// ---------------------------------------------------------------------------
object batalla {
  const nivelMinimo = 40      // aunque no hayas estudiado nada, arrancas con un poquito
  const cadaCuantoMs = 300    // cada cuanto se gasta el cerebro
  const gasto = 1             // cuantos puntos se gastan cada vez
  const premio = 10           // cerebro que recuperas al acertar
  const castigo = 15          // cerebro que perdes al errar
  const desafios = []
  var desafioActual = null
  var peleando = false

  method agregarDesafios(unosDesafios) { desafios.addAll(unosDesafios) }

  // F y G los reenvia a quien corresponda (asi funciona con modoDeJuego.faseActual())
  method elegirIzquierda() { if (peleando) { desafioActual.apretoF() } }
  method elegirDerecha() { if (peleando) { desafioActual.apretoG() } }

  method comenzar() { avisoDeExamen.mostrar({ self.arrancar() }) }

  method arrancar() {
    barraAcademica.modificarNivelAcademico((nivelMinimo - barraAcademica.nivelAcademico()).max(0))
    game.addVisual(examen)
    peleando = true
    game.onTick(cadaCuantoMs, "gastarCerebro", { self.pasarTiempo() })
    self.siguienteDesafio()
  }

  method pasarTiempo() {
    barraAcademica.modificarNivelAcademico(-gasto)
    self.revisarSiTermino()
  }

  method acierto(danio) {
    desafioActual.ocultar()
    examen.recibirDanio(danio)
    barraAcademica.modificarNivelAcademico(premio)
    self.despuesDeResponder()
  }

  method error() {
    game.say(examen, "¡Incorrecto!")
    desafioActual.ocultar()
    barraAcademica.modificarNivelAcademico(-castigo)
    self.despuesDeResponder()
  }

  // si la batalla sigue, viene otro desafio
  method despuesDeResponder() {
    self.revisarSiTermino()
    if (peleando) { self.siguienteDesafio() }
  }

  method revisarSiTermino() {
    if (examen.derrotado()) {
      self.terminar("¡Aprobaste el examen!")
    } else if (barraAcademica.nivelAcademico() == 0) {
      self.terminar("¡Te quedaste sin cerebro! Desaprobaste")
    }
  }

  // un desafio distinto al que acaba de pasar
  method siguienteDesafio() {
    desafioActual = desafios.filter({ unDesafio => unDesafio != desafioActual }).anyOne()
    desafioActual.mostrar()
  }

  method terminar(mensaje) {
    peleando = false
    game.removeTickEvent("gastarCerebro")
    desafioActual.ocultar()
    game.removeVisual(examen)
    examen.reiniciar()
    game.say(barraAcademica, mensaje)
    barraAcademica.terminar()
  }
}

object cargaDeBatalla {
  method cargar() {
    batalla.agregarDesafios([
      self.pregunta("clase", true),
      self.pregunta("inherits", false),
      self.pregunta("polimorfismo", true),
      self.pregunta("mensaje", false),
      self.pregunta("instancia", false),
      self.pregunta("variable", true),
      self.pregunta("override", false),
      self.rafaga("rafagaMachete", 8),
      self.rafaga("rafagaEscribir", 10),
      self.rafaga("rafagaCuadernillo", 12)
    ])
  }

  method pregunta(nombre, correctaEsF) = new Pregunta(
    izquierda = new Cartel(imagen = "batalla/" + nombre + "_F.png", nota = nota_rosa),
    derecha = new Cartel(imagen = "batalla/" + nombre + "_G.png", nota = nota_amarilla),
    correctaEsF = correctaEsF
  )

  method rafaga(nombre, toques) = new Rafaga(
    cartel = new Cartel(imagen = "batalla/" + nombre + ".png", nota = nota_rosa),
    toques = toques
  )
}
