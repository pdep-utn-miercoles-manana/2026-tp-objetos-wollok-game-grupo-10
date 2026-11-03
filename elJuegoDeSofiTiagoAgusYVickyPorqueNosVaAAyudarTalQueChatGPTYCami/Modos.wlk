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
  const descripcion = ""      // lo que dice la imagen de la opcion
  const resultado = ""        // lo que dice la imagen del resultado
  const puntosAcademicos = 0
  const puntosEstres = 0
  var property position = game.origin()
  var mostrandoResultado = false

  method image() = "textos/" + nombre + (if (mostrandoResultado) "_resultado" else "_opcion") + ".png" //juega con los nombres de los assets
  method descripcion() = descripcion
  method resultado() = resultado

  method seleccionado(unModo) {
    self.aplicarEfecto()
    mostrandoResultado = true // para que saber que debe aparecer el resultado
    unModo.mostrarResultado(self)
  }

  method aplicarEfecto() { barraAcademica.aplicar(puntosAcademicos, puntosEstres) }
  method volverAEmpezar() { mostrandoResultado = false }

  // las insignias que se ven abajo del resultado en la historia. Son las consecuencias
  method insignias() = self.insigniaDe("conocimiento_" + puntosAcademicos, puntosAcademicos) + self.insigniaDe("estres", puntosEstres)
  method insigniaDe(archivo, puntos) = if (puntos == 0) [] else [new Insignia(archivo = archivo)]
} // capaz se saca ======================================================

// Te borra todo el estres
class OpcionQueBorraEstres inherits Opcion {
  override method aplicarEfecto() { barraAcademica.aplicar(puntosAcademicos, -barraAcademica.nivelEstres()) }
  override method insignias() = super() + [new Insignia(archivo = "estres_borrado")]
}

// Ademas de los puntos, te guarda un consumible en el inventario
class OpcionQueDaConsumible inherits Opcion {
  const consumible
  const insigniaDelConsumible

  override method aplicarEfecto() {
    super()
    inventario.guardar(consumible)
  }

  override method insignias() = super() + [new Insignia(archivo = insigniaDelConsumible)]
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


object historia inherits Modo(notas = [nota_rosa_chica, nota_amarilla_chica]) {
  const posicionDelResultado = game.at(1, 4)
  const situaciones = [
    new Situacion(nombre = "mascota",
      izquierda = new OpcionDeContexto(nombre = "perro", descripcion = "¡Un perro!"),
      derecha = new OpcionDeContexto(nombre = "gato", descripcion = "¡Un gato!")),

    new Situacion(nombre = "madrugar",
      izquierda = new Opcion(nombre = "dormirMas", descripcion = "Dormir un poco más para estudiar más concentrad@",
        resultado = "TARDE: te volviste a dormir, el teléfono tenía 2% de batería y te despertaste a las 16:00.",
        puntosEstres = 33),
      derecha = new Opcion(nombre = "levantarse", descripcion = "Forzarte a levantarte aunque no entiendas muchos conceptos",
        resultado = "TEMPRANO: mate, galletitas de agua y 2 horas sin saber cómo despejar 2x = 3.",
        puntosAcademicos = 10)),

    new Situacion(nombre = "descanso",
      izquierda = new Opcion(nombre = "cincoMinutos", descripcion = "Usar 5 minutos de celular",
        resultado = "5 MINUTOS: volviste a estudiar, pero no descansaste nada por sobreestimularte viendo el tung.",
        puntosAcademicos = 20, puntosEstres = 33),
      derecha = new OpcionQueDaConsumible(nombre = "treintaMinutos", descripcion = "30 minutos de cosas útiles",
        resultado = "30 MINUTOS: hiciste las tareas de la casa, volviste al estudio recargad@ y te compraste una bebida en el supermercado.",
        puntosAcademicos = 10, consumible = bestia, insigniaDelConsumible = "energetica")),

    new Situacion(nombre = "musica",
      izquierda = new Opcion(nombre = "conMusica", descripcion = "Con un poco de deathcore metal",
        resultado = "CON MÚSICA: no podés distinguir tus pensamientos de los solos de guitarra.",
        puntosAcademicos = 10),
      derecha = new Opcion(nombre = "enSilencio", descripcion = "Como dice tu viejo: en silencio y soledad",
        resultado = "SILENCIO: te funcionó bastante, pero la ansiedad que te generó no tiene nombre.",
        puntosAcademicos = 20, puntosEstres = 33)),

    new Situacion(nombre = "joda",
      izquierda = new OpcionQueBorraEstres(nombre = "irseDeJoda", descripcion = "Irte de joda para desestresar",
        resultado = "IRSE DE JODA: efectivamente te desestresaste."),
      derecha = new Opcion(nombre = "quedarseEstudiando", descripcion = "Ser responsable y quedarte con los diagramas de contexto",
        resultado = "QUEDARSE ESTUDIANDO: te sentís un erudito, pero las historias de tus amigos se ven bastante divertidas...",
        puntosAcademicos = 20, puntosEstres = 33))
  ]

  override method quedanRondas() = rondasJugadas < situaciones.size()
  override method siguienteRonda() = situaciones.get(rondasJugadas)

  // en la historia el resultado es un cartel grande con insignias abajo
  override method mostrarResultado(unaOpcion) {
    unaOpcion.position(posicionDelResultado)
    super(unaOpcion)
    filaDeInsignias.mostrar(unaOpcion.insignias())
  }

  override method sacarResultado() {
    filaDeInsignias.ocultar()
    super()
  }
}


// ---------------------------------------------------------------------
//  ALEATORIO: 12 rondas sacadas al azar de un pozo.
//  1 de cada 3 rondas, una de las notas es un consumible.
//  (los puntos de estres son los que tenia el viejo modo "medio")
// ---------------------------------------------------------------------
object aleatorio inherits Modo(notas = [nota_rosa, nota_amarilla]) {
  const rondasPorPartida = 12
  const suertesDeConsumible = [true, false, false] // chances de que aparezca un consumible
  const yaElegidas = []
  const pozo = [
    new Opcion(nombre = "estudiarDeNoche", descripcion = "Estudiar toda la noche", resultado = "Repasaste todo el temario. Las ojeras llegaron hasta el piso.", puntosAcademicos = 25, puntosEstres = 25),
    new Opcion(nombre = "maratonDeApuntes", descripcion = "Maratón de apuntes con mate", resultado = "Llegaste a la mitad. El mate, a cero.", puntosAcademicos = 20, puntosEstres = 20),
    new Opcion(nombre = "resumenConColores", descripcion = "Armar un resumen con colores", resultado = "Quedó hermoso. Y encima lo entendiste.", puntosAcademicos = 15, puntosEstres = 10),
    new Opcion(nombre = "claseDeConsulta", descripcion = "Ir a la clase de consulta", resultado = "El profe te explicó todo con paciencia.", puntosAcademicos = 15, puntosEstres = 10),
    new Opcion(nombre = "resolverLaGuia", descripcion = "Resolver la guía de ejercicios", resultado = "Te trabaste en el 4, pero el resto salió.", puntosAcademicos = 18, puntosEstres = 15),
    new Opcion(nombre = "tpEnGrupo", descripcion = "Armar un grupo de estudio", resultado = "Uno nunca contestó el grupo. Estudiaste solo.", puntosAcademicos = 20, puntosEstres = 20),
    new Opcion(nombre = "explicarleAUnCompa", descripcion = "Explicarle el tema a un compañero", resultado = "Al explicarlo, por fin lo entendiste vos.", puntosAcademicos = 15, puntosEstres = 5),
    new Opcion(nombre = "leerTeoria", descripcion = "Leer toda la teoría", resultado = "Entendiste la mitad. La otra mitad, mañana.", puntosAcademicos = 15, puntosEstres = 15),
    new Opcion(nombre = "repasarParcialesViejos", descripcion = "Repasar parciales viejos", resultado = "Se repiten los ejercicios. Seguro caen en el examen.", puntosAcademicos = 20, puntosEstres = 13),
    new Opcion(nombre = "bugALas3AM", descripcion = "Practicar código a las 3 AM", resultado = "Encontraste el error: una llave sin cerrar. Otra vez.", puntosAcademicos = 12, puntosEstres = 25),
    new Opcion(nombre = "tutorialYoutube", descripcion = "Ver un tutorial en YouTube", resultado = "Lo entendiste. Hasta que tuviste que aplicarlo.", puntosAcademicos = 10, puntosEstres = 5),
    new Opcion(nombre = "pedirApuntes", descripcion = "Pedir los apuntes a un compañero", resultado = "Letra ilegible, pero algo sirvió.", puntosAcademicos = 10, puntosEstres = 10),
    new Opcion(nombre = "entregarUltimoMomento", descripcion = "Hacer la guía a último momento", resultado = "La terminaste a las 23:59. Respiraste recién a las 00:01.", puntosAcademicos = 20, puntosEstres = 30),
    new Opcion(nombre = "preguntarleAlProfe", descripcion = "Preguntarle una duda al profe", resultado = "Tardó 20 minutos en responder, pero valió la pena.", puntosAcademicos = 15, puntosEstres = 5),
    new Opcion(nombre = "estudiarConAmigos", descripcion = "Estudiar con amigos", resultado = "Veinte minutos de estudio y tres horas de chisme.", puntosAcademicos = 5, puntosEstres = -5),
    new Opcion(nombre = "siesta", descripcion = "Dormir una siestita", resultado = "Te despertaste de noche y los apuntes siguen sin abrir.", puntosAcademicos = -5, puntosEstres = -10),
    new Opcion(nombre = "unEpisodioDeNetflix", descripcion = "Un solo episodio de Netflix", resultado = "Eran las 5 AM y los apuntes seguían sin abrir.", puntosAcademicos = -15, puntosEstres = -15),
    new Opcion(nombre = "salirDeJoda", descripcion = "Salir de joda un ratito", resultado = "Volviste al mediodía y el examen sigue ahí. Sin estudiar.", puntosAcademicos = -20, puntosEstres = -20),
    new Opcion(nombre = "tiktokCincoMinutos", descripcion = "Mirar TikTok cinco minutos", resultado = "Pasaron tres horas. No repasaste nada para el examen.", puntosAcademicos = -10, puntosEstres = -5),
    new Opcion(nombre = "unaPartidaRapida", descripcion = "Jugar una sola partida", resultado = "Son las 4 AM y vas por la sexta. El examen, sin tocar.", puntosAcademicos = -15, puntosEstres = -10),
    new Opcion(nombre = "ordenarElEscritorio", descripcion = "Ordenar el escritorio antes de empezar", resultado = "Quedó impecable. Los apuntes, sin abrir.", puntosAcademicos = -10, puntosEstres = 0),
    new Opcion(nombre = "mateConAmigos", descripcion = "Tomar unos mates con amigas", resultado = "Cuatro horas de charla y cero de estudio para el examen.", puntosAcademicos = -10, puntosEstres = -10),
    new Opcion(nombre = "faltarAClase", descripcion = "Faltar a clase, total hay apuntes", resultado = "Los apuntes eran del cuatrimestre pasado.", puntosAcademicos = -15, puntosEstres = 0),
    new Opcion(nombre = "dormir8Horas", descripcion = "Dormir ocho horas de corrido", resultado = "Energía a full, pero perdiste toda la mañana de estudio.", puntosAcademicos = -5, puntosEstres = -15),
    new Opcion(nombre = "irAlPartido", descripcion = "Ir a ver el partido", resultado = "Ganaron, pero el examen no se estudia solo.", puntosAcademicos = -10, puntosEstres = -15),
    new Opcion(nombre = "mercadoLibre", descripcion = "Mirar cosas en Mercado Libre", resultado = "Compraste un teclado nuevo. De estudiar, nada.", puntosAcademicos = -10, puntosEstres = 0),
    new Opcion(nombre = "caminar", descripcion = "Salir a caminar", resultado = "Te despejaste y volviste a estudiar con la cabeza fresca.", puntosAcademicos = 0, puntosEstres = -15),
    new Opcion(nombre = "respirarHondo", descripcion = "Hacer diez minutos de respiración", resultado = "Estás en paz. Aunque no sepas el tema.", puntosAcademicos = 0, puntosEstres = -20),
    new Opcion(nombre = "gimnasio", descripcion = "Ir al gimnasio", resultado = "Te duele todo, pero la cabeza quedó limpia.", puntosAcademicos = -5, puntosEstres = -20),
    new Opcion(nombre = "seCortoLaLuz", descripcion = "Se corta la luz en pleno estudio", resultado = "Sin luz, sin cargador y sin ganas.", puntosAcademicos = -10, puntosEstres = 20),
    new Opcion(nombre = "cambiaronLaFecha", descripcion = "Cambian la fecha del parcial", resultado = "Ahora es mañana. Te enteraste anoche.", puntosAcademicos = -10, puntosEstres = 25),
    new Opcion(nombre = "compuSinGuardar", descripcion = "Se te cuelga la compu", resultado = "El resumen estaba sin guardar. Qué lindo día.", puntosAcademicos = -15, puntosEstres = 25)
  ]

  override method quedanRondas() = rondasJugadas < rondasPorPartida

  override method siguienteRonda() {
    const disponibles = pozo.filter({ unaOpcion => not yaElegidas.contains(unaOpcion) }).randomized()
    const otra = if (suertesDeConsumible.anyOne()) kiosco.consumibleAlAzar() else disponibles.last()
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


// ---------------------------------------------------------------------
//  Insignias: lo que ganaste / perdiste, abajo del resultado de la historia
// ---------------------------------------------------------------------
class Insignia {
  const archivo
  var property position = game.origin()

  method image() = "historia/" + archivo + ".png"
}

object filaDeInsignias {
  const insignias = []
  const centro = 13
  const altura = 6
  const ancho = 8

  method mostrar(unasInsignias) {
    insignias.addAll(unasInsignias)
    var x = centro - insignias.size() * ancho / 2
    insignias.forEach({ unaInsignia =>
      unaInsignia.position(game.at(x, altura))
      x += ancho
    })
    visuales.mostrar(insignias)
  }

  method ocultar() {
    visuales.ocultar(insignias)
    insignias.clear()
  }
}
