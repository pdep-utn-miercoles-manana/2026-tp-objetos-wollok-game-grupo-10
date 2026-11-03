import wollok.game.*
import Modos.*
import BarraAcad.*
import pantallas.*
import ExamenFinal.*
import Desafios.*

object batalla {
  const nivelMinimo = 40
  const gasto = 1
  const premio = 10
  const castigo = 15
  const pausaAlTerminar = 1500   // para ver como quedo el examen antes del cartel final
  const notas = [nota_rosa, nota_amarilla]
  var desafioActual = null
  var peleando = false


 
  const desafios = [
    new Pregunta(nombre = "clase", correctaEsF = true),
    new Pregunta(nombre = "inherits", correctaEsF = false),
    new Pregunta(nombre = "polimorfismo", correctaEsF = true),
    new Pregunta(nombre = "mensaje", correctaEsF = false),
    new Pregunta(nombre = "instancia", correctaEsF = false),
    new Pregunta(nombre = "variable", correctaEsF = true),
    new Pregunta(nombre = "override", correctaEsF = false),
    new Pregunta(nombre = "super", correctaEsF = false),
    new Pregunta(nombre = "self", correctaEsF = true),
    new Pregunta(nombre = "const", correctaEsF = false),
    new Pregunta(nombre = "object", correctaEsF = true),
    new Pregunta(nombre = "map", correctaEsF = false),
    new Pregunta(nombre = "filter", correctaEsF = true),
    new Pregunta(nombre = "property", correctaEsF = false),
    new Pregunta(nombre = "bloque", correctaEsF = true),
    new Pregunta(nombre = "abstracto", correctaEsF = false),
    new Pregunta(nombre = "noEntiende", correctaEsF = true),
    new Pregunta(nombre = "onTick", correctaEsF = false),
    new Pregunta(nombre = "set", correctaEsF = true),
    new Rafaga(nombre = "rafagaMachete", toques = 8),
    new Rafaga(nombre = "rafagaEscribir", toques = 10),
    new Rafaga(nombre = "rafagaCuadernillo", toques = 12)
  ]

  // F y G se los pasa al desafio que este en pantalla
  method elegirIzquierda() { if (peleando) { desafioActual.apretoF() } }
  method elegirDerecha() { if (peleando) { desafioActual.apretoG() } }

  method comenzar() { avisoDeExamen.mostrar({ self.arrancar() }) }

  method arrancar() {
    barraAcademica.asegurarNivel(nivelMinimo)
    visuales.mostrar(notas + [examen])
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
      self.terminar(pantallaAprobaste)
    } else if (barraAcademica.sinConocimiento()) {
      self.terminar(pantallaDesaprobaste)
    }
  }

  method siguienteDesafio() {
    desafioActual = desafios.filter({ unDesafio => unDesafio != desafioActual }).anyOne()
    desafioActual.mostrar()
  }

  // frena la pelea, deja ver el examen un ratito y muestra si aprobaste o no
  method terminar(pantallaDeResultado) {
    peleando = false
    game.removeTickEvent("gastarCerebro")
    desafioActual.ocultar()
    game.schedule(pausaAlTerminar, { self.mostrarResultado(pantallaDeResultado) })
  }

  method mostrarResultado(pantallaDeResultado) {
    visuales.ocultar(notas + [examen])
    examen.reiniciar()
    pantallaDeResultado.mostrar({ modoDeJuego.volverAlMenu() })
  }
}
