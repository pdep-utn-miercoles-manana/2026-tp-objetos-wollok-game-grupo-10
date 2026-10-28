import BarraAcad.*
class Consumible{
  var property position=game.at(0, 0)
  const nombreArchivo
  const puntosAcademicos 
  const puntosEstres 
  
  method image() = "Consumibles/" + nombreArchivo + ".gif"
  method imagenInventario() = "Consumibles/" + nombreArchivo + "_mariokart.gif"
  
  method consumido() {
     barraAcademica.modificarNivelAcademico(puntosAcademicos)
     barraAcademica.modificarNivelEstres(puntosEstres)
  }

  method seleccionado() {
    if (inventario.hayLugar()){
          game.removeVisual(self)
          inventario.guardar(self)
  }
   else { 
      game.say(espacio1, "inventario lleno")
      game.removeVisual(self)
   }
  }
 }

const chocolate = new Consumible( nombreArchivo= "choco" , puntosAcademicos =10, puntosEstres=0)
const bestia = new Consumible(nombreArchivo= "energetica", puntosAcademicos=15, puntosEstres=5) 

//NUEVO: a veces te regalan un objeto (lo llama Camino.presentarOpciones despues de cada eleccion)
object regalos {
  const probabilidad = 25 // % de chances de que te regalen algo

  method posibles() = [chocolate, bestia]

  method sortear() {
    if (0.randomUpTo(100) < probabilidad) { self.regalar(self.posibles().anyOne()) }
  }

  method regalar(unConsumible) {
    if (inventario.hayLugar()) {
      inventario.guardar(unConsumible)
      game.say(espacio1, "¡Te regalaron un objeto!")
    } else {
      game.say(espacio1, "Te querían regalar algo pero el inventario está lleno")
    }
  }
}

object inventario {
  var property items = []

  method guardar(unItem) {
    if (self.hayLugar()) {
      items.add(unItem)
    } else {
      game.say(espacio1, "Inventario lleno")
    }
  }

   method hayLugar() = items.size() < 2

  method consumir() {
    if (items.isEmpty()) {
      game.say(espacio1, "Inventario vacío") //lifo
    } else {
      const item = items.last()
      items.remove(item)
      item.consumido()
    }
  }
}

class EspacioInventario{
   var property position = game.at(0,0)
   const numeroPosicionInventario

   method image() =
    if (numeroPosicionInventario < inventario.items().size())
      inventario.items().get(numeroPosicionInventario).imagenInventario() // get me da lo de una posicion
    else
      "Consumibles/cuadrito_azul.png"
}

const espacio1 = new EspacioInventario(position = game.at(26, 11), numeroPosicionInventario = 0)
const espacio2 = new EspacioInventario(position = game.at(29, 11), numeroPosicionInventario = 1)


/*object sinConsumible{
  method nombre() = "nada"
  method image() = "vacio.jpg"
  method usar(){}
}

object inventario{
  var property position = game.at(0,0)
  var consumibles = [sinConsumible, sinConsumible]
  method consumibles() = consumibles
  const capacidad = 2
  method capacidad() = capacidad


  method agregar(unConsumible){
    if(self.estaVacio()){//si esta vacia
      consumibles = [unConsumible, sinConsumible] //lo agrego 1ro 
    } else if(self.estaLleno()){ //si tiene lleno el inventario
      self.error("El inventario está lleno, se pierde " + unConsumible.nombre() + " :(") //?? creo
    } else { //tiene 1 objeto
      var primero = consumibles.head()
      consumible = [primero, unConsumible]
    }
  }

  method estaVacio() = consumibles == [sinConsumible, sinConsumible]
  method tieneUnObjeto() = consumibles == [Consumible, sinConsumible] 
  method estaLleno() = (not consumibles.contains(sinConsumible))

  method usar(){
    consumibles.head().usar()
    self.acomodarConsumibles()
  }

  method acomodarConsumibles(){
    if(self.estaLleno()){
      var ultimo = consumibles.last()
      consumibles = [ultimo, sinConsumible]
    } else { //tiene 1 objeto
      self.vaciar()
    } //el vacio no hace falta ya que no cambia la lista
  }

  method vaciar(){ consumibles = [sinConsumible, sinConsumible] }

///////////////////////////////////////////////// OTRA OPCION 

  var property position = game.at(0,0)
  var consumibles = []
  const capacidad = 2
  method consumibles() = consumibles
  method capacidad() = capacidad

  method estaLleno() = consumibles.size()>= capacidad

  method agregar(unConsumible){
    if(not consumibles.estaLleno() ){
      consumibles.add(unConsumible)
    } else {
      self.error("Esta el inventario lleno, se pierde " + unConsumible.nombre() + ".") //?? creo
    }
  }

  method usar(){
    var primero = consumibles.head()
    primero.usar()
    consumibles.remove(primero)
  }

  method vaciar() { consumibles = [] }

  method texto(){ 
    var text = ""
    if (consumibles.isEmpty()){
      return "vacio"
    } else { 
      return consumibles.forEach({ consumible => if(text==""){text = consumible.nombre()}else{text += ", "+consumible.nombre()}})
    }
  }*/