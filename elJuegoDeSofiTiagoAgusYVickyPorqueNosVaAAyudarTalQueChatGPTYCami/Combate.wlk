import Caminos.*
import BarraAcad.*
import pantallas.*
import ExamenFinal.*
import Desafios.*

object batalla {
  const nivelMinimo = 40
  const gasto = 1
  const premio = 10
  const castigo = 15
  const desafios = []
  var desafioActual = null
  var peleando = false

  method agregarDesafios(unosDesafios) { desafios.addAll(unosDesafios) }

  // F y G se los pasa al desafio que este en pantalla
  method elegirIzquierda() { if (peleando) { desafioActual.apretoF() } }
  method elegirDerecha() { if (peleando) { desafioActual.apretoG() } }

  method comenzar() { avisoDeExamen.mostrar({ self.arrancar() }) }

  method arrancar() {
    barraAcademica.asegurarNivel(nivelMinimo)
    game.addVisual(examen)
    peleando = true
    game.onTick(300, "gastarCerebro", { self.pasarTiempo() })
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
