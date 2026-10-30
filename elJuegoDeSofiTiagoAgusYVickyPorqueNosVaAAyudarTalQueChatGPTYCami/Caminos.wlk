import Consumibles.*
import pantallas.*
import BarraAcad.*
import segundaParte.*

 class Camino{
    var paresDeCaminos=[]
    var opcionesUsadas= []
    var opciones = []
    const limiteEstres = 100
    // cada ronda tiene al menos una situacion; la otra nota sale consumible 1 de cada 3 veces (sino, otra situacion)
    const suertesDeConsumible = [true, false, false]
    var esperandoEleccion = false 
    const rondasPorPartida = 12 // el pozo tiene muchas situaciones, pero cada partida juega solo 12
   

  method izquierda() = opciones.first()
  method derecha() = opciones.last()

  method elegirIzquierda() { if (self.puedeElegir()) { self.elegir(self.izquierda()) } }
  method elegirDerecha() { if (self.puedeElegir()) { self.elegir(self.derecha()) } }

  method elegir(unLado){
    esperandoEleccion = false //NUEVO
    opciones.forEach({unaOpcion => game.removeVisual(unaOpcion)})
    self.gastar(unLado) // si elegiste una situacion, esa se gasta; la otra (si habia) queda para mas adelante
    unLado.seleccionado()
  }


  // una situacion del pozo que todavia no este en pantalla (no la gasta)
  method situacionAlAzar() = paresDeCaminos.filter({ unaOpcion => not opciones.contains(unaOpcion) }).anyOne()

  // saca la situacion del pozo (solo si todavia esta ahi, asi nunca se gasta dos veces)
  method gastar(unaSituacion) {
    if (paresDeCaminos.contains(unaSituacion)) {
      paresDeCaminos.remove(unaSituacion)
      opcionesUsadas.add(unaSituacion)
    }
  }

  // la 2da nota es consumible por suerte, o porque ya no queda otra situacion para mostrar
  method segundaEsConsumible() = paresDeCaminos.size() < 2 or suertesDeConsumible.anyOne()

  // Cada ronda gasta exactamente UNA situacion, asi siempre son tantas rondas como situaciones hay:
  //  - situacion + consumible: se gasta la situacion que se muestra (la elijas o no)
  //  - situacion + situacion:  se gasta solo la que elijas, la otra vuelve a quedar en el pozo
  method generarOpciones() {
    opciones.clear()
    opciones.add(self.situacionAlAzar())
    if (self.segundaEsConsumible()) {
      self.gastar(opciones.first())
      opciones.add(kiosco.consumibleAlAzar())
    } else {
      opciones.add(self.situacionAlAzar())
    }
    if ([true, false].anyOne()) { opciones = opciones.reverse() } // asi el consumible no cae siempre del mismo lado
    opciones.first().position(nota_rosa.posicionDelTexto())     // F -> nota rosa
    opciones.last().position(nota_amarilla.posicionDelTexto())  // G -> nota amarilla
  }

  //HACER FUNCION TERMINAR
  method reiniciar(){ 
     paresDeCaminos.addAll(opcionesUsadas) 
     opcionesUsadas.clear()
     opciones.clear()
     esperandoEleccion = false
  }

  method agregarOpciones(unasOpciones) { paresDeCaminos.addAll(unasOpciones) }
  method puedeElegir() = esperandoEleccion

  method perdioPorEstres() = barraAcademica.estresAlcanza(limiteEstres)
  method sinOpciones() = opcionesUsadas.size() >= rondasPorPartida or paresDeCaminos.isEmpty() // cada ronda gasta 1 situacion (el consumible no se gasta)
  // terminada la preparacion arranca la batalla contra el examen (ver segundaParte.wlk)
  method alTerminarRondas() { modoDeJuego.empezarBatalla() }

  // muestra la siguiente ronda de opciones o, si corresponde, termina el juego
  method presentarOpciones() {
    if (self.perdioPorEstres()) {
      self.terminar("¡Perdiste! Te estresaste demasiado")
    } else if (self.sinOpciones()) {
      self.alTerminarRondas()
    } else {
      self.mostrarOpciones()
    }
  }

  method mostrarOpciones() {
    self.generarOpciones()
    opciones.forEach({unaOpcion => game.addVisual(unaOpcion)})
    esperandoEleccion = true
  }

  method terminar(mensaje) {
    game.say(barraAcademica, mensaje)
    barraAcademica.terminar()
  }
}

const caminoFacil = new Camino () //Intentar De lograr modo historia y random

const caminoMedio = new Camino ()

const caminoDificil = new Camino()

//ESTO SON LAS FOTOS DE LAS ETIQUETAS//
class Nota{
  const color
  var property  position
  method image()="nota_" + color + ".gif"
  method posicionDelTexto() = position.right(1).up(4)
}
//-----------------------------------//


const nota_rosa = new Nota(color = "rosa", position = game.at(1,3))
const nota_amarilla = new Nota(color = "amarilla", position = game.at(12,3))


object modoDeJuego {
    var caminoActual = caminoFacil
    var faseActual = caminoFacil // el camino de preparacion o, despues, la batalla: los dos entienden F / G
    method cambiarA(unCamino){
      if (menu.estaMostrandose()) {
        caminoActual = unCamino
        faseActual = unCamino
        menu.ocultar()
        instructivo.mostrar({ self.siguienteRonda() })
      }
    }

    method siguienteRonda() { faseActual.presentarOpciones() }

    method faseActual() = faseActual

    method empezarBatalla() {
      faseActual = batalla
      batalla.comenzar()
    }

    method caminoActual() = caminoActual

    method resetear(){
        caminoActual.reiniciar()
        faseActual = caminoActual
        inventario.vaciar() // el inventario no pasa de una partida a la otra
    }

}

class Opcion{
  const nombre 
  const descripcion 
  const resultado

  const puntosAcademicos = 0
  const puntosEstres = 0
  const tiempoDeLectura = 2500 
  var property position = game.origin() 
  var mostrandoResultado = false 

  method seleccionado(){
     barraAcademica.aplicar(puntosAcademicos, puntosEstres)
     mostrandoResultado = true // el texto que se dibuja es el resultado
     game.addVisual(self) 
     game.schedule(tiempoDeLectura, { self.seguir() }) 
     //modoDeJuego.caminoActual().presentarOpciones() 


  }

  method seguir() {
     game.removeVisual(self)
     mostrandoResultado = false
     modoDeJuego.siguienteRonda()
  }

  //method position(x,y) =game.at(x,y)
  method position(x,y) { position = game.at(x,y) } //CAMBIADO: ahora guarda la posicion
  method text(unTexto) = unTexto
  method image() = "textos/" + nombre + (if (mostrandoResultado) "_resultado" else "_opcion") + ".png"
  method descripcion() = descripcion
  method resultado() = resultado

}
