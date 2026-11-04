import wollok.game.*
import pantallas.*
import BarraAcad.*
import Consumibles.*
import Combate.*

class Nota {
  const color
  const tamanio = ""        // "" = nota grande, "_chica" = nota chica  --> esto es porque varia en cada modo
  const altoDelTexto = 4    // cuantas celdas arriba de la nota va el texto
  const property position

  method image() = "nota_" + color + tamanio + ".gif"
  method posicionDelTexto() = position.right(1).up(altoDelTexto)
}

const nota_rosa = new Nota(color = "rosa", position = game.at(1, 3))
const nota_amarilla = new Nota(color = "amarilla", position = game.at(12, 3))
const nota_rosa_chica = new Nota(color = "rosa", tamanio = "_chica", altoDelTexto = 2, position = game.at(3, 3))
const nota_amarilla_chica = new Nota(color = "amarilla", tamanio = "_chica", altoDelTexto = 2, position = game.at(15, 3))


class Opcion {
  const nombre
  const puntosAcademicos = 0
  const puntosEstres = 0
  var property position = game.origin()
  var mostrandoResultado = false

  method image() = "textos/" + nombre + (if (mostrandoResultado) "_resultado" else "_opcion") + ".png" //juega con los nombres de los assets

  method seleccionado(unModo) {
    self.aplicarEfecto()
    mostrandoResultado = true // para que saber que debe aparecer el resultado
    unModo.mostrarResultado(self)
  }

  method aplicarEfecto() { barraAcademica.aplicar(puntosAcademicos, puntosEstres) }
  method volverAEmpezar() { mostrandoResultado = false }

  // el texto que aparece en la historia: que subio y que bajo
  method resumen() = (self.cambio("conocimiento", puntosAcademicos) + self.cambio("estrés", puntosEstres)).join(" ")
  method cambio(algo, puntos) =
    if (puntos > 0) ["¡Subió tu " + algo + "!"]
    else if (puntos < 0) ["¡Bajó tu " + algo + "!"]
    else []
}

// Ademas de los puntos, te guarda un consumible en el inventario
class OpcionQueDaConsumible inherits Opcion {
  const consumible

  override method aplicarEfecto() {
    super()
    inventario.guardar(consumible)
  }
}

// Solo da contexto: no suma ni resta nada y pasa directo a la proxima ronda
class OpcionDeContexto inherits Opcion {
  override method seleccionado(unModo) { unModo.presentarRonda() }
}


// ---------------------------------------------------------------------
//  Rondas: las dos opciones que se ven a la vez
// ---------------------------------------------------------------------
class Ronda {
  const property izquierda
  const property derecha

  method visuales() = [izquierda, derecha]
}

// Una ronda de la historia: ademas tiene un cartel arriba que cuenta que pasa
class Situacion inherits Ronda {
  const nombre
  const property position = game.at(1, 11)

  method image() = "historia/" + nombre + "_situacion.png"
  override method visuales() = super() + [self]
}


// ---------------------------------------------------------------------
//  Modo: todo lo que comparten historia y aleatorio
// ---------------------------------------------------------------------
class Modo {
  const notas                    // las dos notas sobre las que van las opciones (F y G)
  const limiteEstres = 100
  const tiempoMinimoDeLectura = 1000
  var rondasJugadas = 0
  var rondaActual = null
  var eligiendo = false
  var resultadoEnPantalla = null
  var puedeSeguir = false

  // ----- lo unico que cambia en cada modo -----
  method quedanRondas()
  method siguienteRonda()

  method empezar() {
    visuales.mostrar(notas)
    self.presentarRonda()
  }

  method reiniciar() {
    visuales.ocultar(notas)
    rondasJugadas = 0
    rondaActual = null
    eligiendo = false
    resultadoEnPantalla = null
  }

  // muestra la proxima ronda, o pierde por estres, o arranca el examen
  method presentarRonda() {
    if (barraAcademica.estresAlcanza(limiteEstres)) {
      game.say(barraAcademica, "¡Perdiste! Te estresaste demasiado")
      modoDeJuego.volverAlMenu()
    } else if (self.quedanRondas()) {
      self.mostrarRonda()
    } else {
      visuales.ocultar(notas)
      modoDeJuego.empezarBatalla()
    }
  }

  method mostrarRonda() {
    rondaActual = self.siguienteRonda()
    rondaActual.izquierda().position(notas.first().posicionDelTexto())
    rondaActual.derecha().position(notas.last().posicionDelTexto())
    visuales.mostrar(rondaActual.visuales())
    eligiendo = true
  }

  // ----- teclas: F = izquierda, G = derecha -----
  method elegirIzquierda() { self.apretar(rondaActual.izquierda()) }
  method elegirDerecha() { self.apretar(rondaActual.derecha()) }

  method apretar(unaOpcion) {
    if (resultadoEnPantalla != null) {
      self.seguirLeyendo()
    } else if (eligiendo) {
      self.elegir(unaOpcion)
    }
  }

  method elegir(unaOpcion) {
    eligiendo = false
    rondasJugadas += 1
    visuales.ocultar(rondaActual.visuales())
    unaOpcion.seleccionado(self)
  }

  // ----- el resultado queda en pantalla hasta que apretes F o G -----
  method mostrarResultado(unaOpcion) {
    resultadoEnPantalla = unaOpcion
    puedeSeguir = false
    game.addVisual(unaOpcion)
    game.schedule(tiempoMinimoDeLectura, { self.dejarSeguir() })
  }

  method dejarSeguir() {
    puedeSeguir = true
    visuales.mostrar([pistaSeguir])
  }

  method seguirLeyendo() {
    if (puedeSeguir) {
      self.sacarResultado()
      self.presentarRonda()
    }
  }

  method sacarResultado() {
    visuales.ocultar([resultadoEnPantalla, pistaSeguir])
    resultadoEnPantalla.volverAEmpezar()
    resultadoEnPantalla = null
  }
}


class ModoHistoria inherits Modo {
  const posicionDelResultado = game.at(1, 4)
  const situaciones = [
    new Situacion(nombre = "mascota",
      izquierda = new OpcionDeContexto(nombre = "perro"),
      derecha = new OpcionDeContexto(nombre = "gato")),

    new Situacion(nombre = "madrugar",
      izquierda = new Opcion(nombre = "dormirMas", puntosEstres = 33),
      derecha = new Opcion(nombre = "levantarse", puntosAcademicos = 10)),

    new Situacion(nombre = "descanso",
      izquierda = new Opcion(nombre = "cincoMinutos", puntosAcademicos = 20, puntosEstres = 33),
      derecha = new OpcionQueDaConsumible(nombre = "treintaMinutos", puntosAcademicos = 10, consumible = bestia)),

    new Situacion(nombre = "musica",
      izquierda = new Opcion(nombre = "conMusica", puntosAcademicos = 10),
      derecha = new Opcion(nombre = "enSilencio", puntosAcademicos = 20, puntosEstres = 33)),

    new Situacion(nombre = "joda",
      izquierda = new Opcion(nombre = "irseDeJoda", puntosEstres = -100), // BORRAR ESTRES: la barra no baja de 0
      derecha = new Opcion(nombre = "quedarseEstudiando", puntosAcademicos = 20, puntosEstres = 33)),

    new Situacion(nombre = "chocolatito",
      izquierda = new OpcionQueDaConsumible(nombre = "comprarChocolatito", consumible = chocolate),
      derecha = new Opcion(nombre = "noComprarChocolatito", puntosAcademicos = 20, puntosEstres = 33)),

    new Situacion(nombre = "amigas",
      izquierda = new OpcionQueDaConsumible(nombre = "conAmigas", puntosAcademicos = 10, puntosEstres = -33, consumible = chocolate),
      derecha = new Opcion(nombre = "seguirSolo", puntosAcademicos = 20, puntosEstres = 33)),

    new Situacion(nombre = "diaAnterior",
      izquierda = new Opcion(nombre = "estudiarTodoElDia", puntosAcademicos = 30, puntosEstres = 66),
      derecha = new Opcion(nombre = "descansar", puntosEstres = -100)) // BORRAR ESTRES: la barra no baja de 0
  ]

  override method quedanRondas() = rondasJugadas < situaciones.size()
  override method siguienteRonda() = situaciones.get(rondasJugadas)

  // en la historia el resultado es un cartel grande y un globito que dice que cambio
  override method mostrarResultado(unaOpcion) {
    unaOpcion.position(posicionDelResultado)
    super(unaOpcion)
    if (unaOpcion.resumen() != "") game.say(unaOpcion, unaOpcion.resumen())
  }
}

const historia = new ModoHistoria(notas = [nota_rosa_chica, nota_amarilla_chica])


class ModoAleatorio inherits Modo {
  const rondasPorPartida = 12
  const suertesDeConsumible = [true, false, false] // chances de que aparezca un consumible
  const yaElegidas = []
  const pozo = [
    new Opcion(nombre = "estudiarDeNoche", puntosAcademicos = 25, puntosEstres = 25),
    new Opcion(nombre = "maratonDeApuntes", puntosAcademicos = 20, puntosEstres = 20),
    new Opcion(nombre = "resumenConColores", puntosAcademicos = 15, puntosEstres = 10),
    new Opcion(nombre = "claseDeConsulta", puntosAcademicos = 15, puntosEstres = 10),
    new Opcion(nombre = "resolverLaGuia", puntosAcademicos = 18, puntosEstres = 15),
    new Opcion(nombre = "tpEnGrupo", puntosAcademicos = 20, puntosEstres = 20),
    new Opcion(nombre = "explicarleAUnCompa", puntosAcademicos = 15, puntosEstres = 5),
    new Opcion(nombre = "leerTeoria", puntosAcademicos = 15, puntosEstres = 15),
    new Opcion(nombre = "repasarParcialesViejos", puntosAcademicos = 20, puntosEstres = 13),
    new Opcion(nombre = "bugALas3AM", puntosAcademicos = 12, puntosEstres = 25),
    new Opcion(nombre = "tutorialYoutube", puntosAcademicos = 10, puntosEstres = 5),
    new Opcion(nombre = "pedirApuntes", puntosAcademicos = 10, puntosEstres = 10),
    new Opcion(nombre = "entregarUltimoMomento", puntosAcademicos = 20, puntosEstres = 30),
    new Opcion(nombre = "preguntarleAlProfe", puntosAcademicos = 15, puntosEstres = 5),
    new Opcion(nombre = "estudiarConAmigos", puntosAcademicos = 5, puntosEstres = -5),
    new Opcion(nombre = "siesta", puntosAcademicos = -5, puntosEstres = -10),
    new Opcion(nombre = "unEpisodioDeNetflix", puntosAcademicos = -15, puntosEstres = -15),
    new Opcion(nombre = "salirDeJoda", puntosAcademicos = -20, puntosEstres = -20),
    new Opcion(nombre = "tiktokCincoMinutos", puntosAcademicos = -10, puntosEstres = -5),
    new Opcion(nombre = "unaPartidaRapida", puntosAcademicos = -15, puntosEstres = -10),
    new Opcion(nombre = "ordenarElEscritorio", puntosAcademicos = -10, puntosEstres = 0),
    new Opcion(nombre = "mateConAmigos", puntosAcademicos = -10, puntosEstres = -10),
    new Opcion(nombre = "faltarAClase", puntosAcademicos = -15, puntosEstres = 0),
    new Opcion(nombre = "dormir8Horas", puntosAcademicos = -5, puntosEstres = -15),
    new Opcion(nombre = "irAlPartido", puntosAcademicos = -10, puntosEstres = -15),
    new Opcion(nombre = "mercadoLibre", puntosAcademicos = -10, puntosEstres = 0),
    new Opcion(nombre = "caminar", puntosAcademicos = 0, puntosEstres = -15),
    new Opcion(nombre = "respirarHondo", puntosAcademicos = 0, puntosEstres = -20),
    new Opcion(nombre = "gimnasio", puntosAcademicos = -5, puntosEstres = -20),
    new Opcion(nombre = "seCortoLaLuz", puntosAcademicos = -10, puntosEstres = 20),
    new Opcion(nombre = "cambiaronLaFecha", puntosAcademicos = -10, puntosEstres = 25),
    new Opcion(nombre = "compuSinGuardar", puntosAcademicos = -15, puntosEstres = 25)
  ]

  override method quedanRondas() = rondasJugadas < rondasPorPartida

  override method siguienteRonda() {
    const disponibles = pozo.filter({ unaOpcion => not yaElegidas.contains(unaOpcion) }).randomized()
    const otra = if (suertesDeConsumible.anyOne()) sorteoDeConsumibles.unoAlAzar() else disponibles.last()
    const par = [disponibles.first(), otra].randomized()   // asi el consumible no cae siempre del mismo lado
    return new Ronda(izquierda = par.first(), derecha = par.last())
  }

  // lo que elegiste no vuelve a salir en esta partida
  override method elegir(unaOpcion) {
    yaElegidas.add(unaOpcion)
    super(unaOpcion)
  }

  override method reiniciar() {
    super()
    yaElegidas.clear()
  }
}

const aleatorio = new ModoAleatorio(notas = [nota_rosa, nota_amarilla])


// ---------------------------------------------------------------------
//  modoDeJuego: sabe que modo se esta jugando y a quien le llegan F y G
//  (el menu, el instructivo, el modo o la batalla)
// ---------------------------------------------------------------------
object modoDeJuego {
  var modoActual = historia
  var faseActual = menu

  method faseActual() = faseActual

  method elegirModo(unModo) {
    if (menu.estaMostrandose()) {
      modoActual = unModo
      menu.ocultar()
      faseActual = instructivo
      instructivo.mostrar({ self.empezarPartida() })
    }
  }

  method empezarPartida() {
    faseActual = modoActual
    modoActual.empezar()
  }

  method empezarBatalla() {
    faseActual = batalla
    batalla.comenzar()
  }

  method volverAlMenu() {
    barraAcademica.reiniciar()
    modoActual.reiniciar()
    inventario.vaciar()     // el inventario no pasa de una partida a la otra
    faseActual = menu
    menu.mostrar()
  }
}
