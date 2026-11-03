import Caminos.*
import pantallas.*
import BarraAcad.*
import Consumibles.*

class NotaChica inherits Nota {
  override method image() = "nota_" + color + "_chica.gif"
  override method posicionDelTexto() = position.right(1).up(2)
}

const nota_rosa_chica = new NotaChica(color = "rosa", position = game.at(3, 3))
const nota_amarilla_chica = new NotaChica(color = "amarilla", position = game.at(15, 3))


class Situacion inherits Pantalla {
  const property izquierda
  const property derecha
}


class OpcionHistoria inherits Opcion {
  const posicionDelResultado = game.at(1, 4)

  override method seleccionado() {
    self.aplicarEfecto()
    mostrandoResultado = true
    self.position(posicionDelResultado)
    game.addVisual(self)
    filaDeInsignias.mostrar(self.insignias())
    modoDeJuego.caminoActual().esperarLectura(self)
  }

  method aplicarEfecto() { barraAcademica.aplicar(puntosAcademicos, puntosEstres) }

  method insignias() = self.insigniaDe("conocimiento_" + puntosAcademicos, puntosAcademicos) + self.insigniaDe("estres", puntosEstres)
  method insigniaDe(archivo, puntos) = if (puntos == 0) [] else [new Insignia(archivo = archivo)]

  override method seguir() {
    filaDeInsignias.ocultar()
    super()
  }
}

class OpcionQueBorraEstres inherits OpcionHistoria {
  override method aplicarEfecto() { barraAcademica.aplicar(puntosAcademicos, -barraAcademica.nivelEstres()) }
  override method insignias() = super() + [new Insignia(archivo = "estres_borrado")]
}

class OpcionQueDaConsumible inherits OpcionHistoria {
  const consumible
  const insigniaDelConsumible

  override method aplicarEfecto() {
    super()
    inventario.guardar(consumible)
  }

  override method insignias() = super() + [new Insignia(archivo = insigniaDelConsumible)]
}

class OpcionDeContexto inherits Opcion {
  override method seleccionado() { modoDeJuego.siguienteRonda() }
}


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
      game.addVisual(unaInsignia)
      x += ancho
    })
  }

  method ocultar() {
    insignias.forEach({ unaInsignia => game.removeVisual(unaInsignia) })
    insignias.clear()
  }
}


class CaminoHistoria inherits Camino {
  const situaciones = []
  var numeroDeSituacion = 0
  var resultadoEnPantalla = null
  var puedeSeguir = false
  const tiempoMinimoDeLectura = 1000

  method agregarSituaciones(unasSituaciones) { situaciones.addAll(unasSituaciones) }
  method situacionActual() = situaciones.get(numeroDeSituacion)

  override method elegirIzquierda() { if (self.leyendoResultado()) self.seguirLeyendo() else super() }
  override method elegirDerecha() { if (self.leyendoResultado()) self.seguirLeyendo() else super() }

  override method elegir(unLado) {
    self.situacionActual().ocultar()
    self.sacar([nota_rosa_chica, nota_amarilla_chica])
    numeroDeSituacion += 1
    super(unLado)
  }

  override method generarOpciones() {
    opciones.clear()
    opciones.add(self.situacionActual().izquierda())
    opciones.add(self.situacionActual().derecha())
    opciones.first().position(nota_rosa_chica.posicionDelTexto())
    opciones.last().position(nota_amarilla_chica.posicionDelTexto())
  }

  override method mostrarOpciones() {
    self.sacar([nota_rosa, nota_amarilla])
    self.poner([nota_rosa_chica, nota_amarilla_chica])
    self.situacionActual().mostrar()
    super()
  }

  override method sinOpciones() = numeroDeSituacion >= situaciones.size()

  method leyendoResultado() = resultadoEnPantalla != null

  method esperarLectura(unaOpcion) {
    resultadoEnPantalla = unaOpcion
    puedeSeguir = false
    game.schedule(tiempoMinimoDeLectura, { puedeSeguir = true })
  }

  method seguirLeyendo() {
    if (puedeSeguir) {
      const opcion = resultadoEnPantalla
      resultadoEnPantalla = null
      opcion.seguir()
    }
  }

  override method alTerminarRondas() {
    self.volverANotasGrandes()
    super()
  }

  override method reiniciar() {
    super()
    numeroDeSituacion = 0
    resultadoEnPantalla = null
    self.volverANotasGrandes()
  }

  method volverANotasGrandes() {
    self.sacar([nota_rosa_chica, nota_amarilla_chica])
    self.poner([nota_rosa, nota_amarilla])
  }

  method poner(visuales) { visuales.forEach({ unVisual => if (not game.hasVisual(unVisual)) game.addVisual(unVisual) }) }
  method sacar(visuales) { visuales.forEach({ unVisual => if (game.hasVisual(unVisual)) game.removeVisual(unVisual) }) }
}

const caminoHistoria = new CaminoHistoria()


object cargaDeHistoria {
  // en la historia el estres pega fuerte: cada vez que sube, sube un tercio de la barra.
  // Es 34 y no 33 para que con 3 subas llegue al limite (100) y pierdas.
  const unTercioDeEstres = 33

  method cargar() {
    caminoHistoria.agregarSituaciones([
      self.situacion("mascota",
        new OpcionDeContexto(nombre = "perro", descripcion = "¡Un perro!", resultado = ""),
        new OpcionDeContexto(nombre = "gato", descripcion = "¡Un gato!", resultado = "")),

      self.situacion("madrugar",
        new OpcionHistoria(nombre = "dormirMas", descripcion = "Dormir un poco más para estudiar más concentrad@",
          resultado = "TARDE: te volviste a dormir, el teléfono tenía 2% de batería y te despertaste a las 16:00.",
          puntosEstres = unTercioDeEstres),
        new OpcionHistoria(nombre = "levantarse", descripcion = "Forzarte a levantarte aunque no entiendas muchos conceptos",
          resultado = "TEMPRANO: mate, galletitas de agua y 2 horas sin saber cómo despejar 2x = 3.",
          puntosAcademicos = 10)),

      self.situacion("descanso",
        new OpcionHistoria(nombre = "cincoMinutos", descripcion = "Usar 5 minutos de celular",
          resultado = "5 MINUTOS: volviste a estudiar, pero no descansaste nada por sobreestimularte viendo el tung.",
          puntosAcademicos = 20, puntosEstres = unTercioDeEstres),
        new OpcionQueDaConsumible(nombre = "treintaMinutos", descripcion = "30 minutos de cosas útiles",
          resultado = "30 MINUTOS: hiciste las tareas de la casa, volviste al estudio recargad@ y te compraste una bebida en el supermercado.",
          puntosAcademicos = 10, consumible = bestia, insigniaDelConsumible = "energetica")),

      self.situacion("musica",
        new OpcionHistoria(nombre = "conMusica", descripcion = "Con un poco de deathcore metal",
          resultado = "CON MÚSICA: no podés distinguir tus pensamientos de los solos de guitarra.",
          puntosAcademicos = 10),
        new OpcionHistoria(nombre = "enSilencio", descripcion = "Como dice tu viejo: en silencio y soledad",
          resultado = "SILENCIO: te funcionó bastante, pero la ansiedad que te generó no tiene nombre.",
          puntosAcademicos = 20, puntosEstres = unTercioDeEstres)),

      self.situacion("joda",
        new OpcionQueBorraEstres(nombre = "irseDeJoda", descripcion = "Irte de joda para desestresar",
          resultado = "IRSE DE JODA: efectivamente te desestresaste."),
        new OpcionHistoria(nombre = "quedarseEstudiando", descripcion = "Ser responsable y quedarte con los diagramas de contexto",
          resultado = "QUEDARSE ESTUDIANDO: te sentís un erudito, pero las historias de tus amigos se ven bastante divertidas...",
          puntosAcademicos = 20, puntosEstres = unTercioDeEstres))
    ])
  }

  method situacion(nombre, izquierda, derecha) = new Situacion(
    imagen = "historia/" + nombre + "_situacion.png",
    position = game.at(1, 11),
    izquierda = izquierda,
    derecha = derecha
  )
}
