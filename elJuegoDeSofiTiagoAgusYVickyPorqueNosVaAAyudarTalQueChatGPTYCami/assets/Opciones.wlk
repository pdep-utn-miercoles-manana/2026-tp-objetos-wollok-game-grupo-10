import Caminos.*

//NUEVO: las opciones de cada camino.
//Mientras mas dificil el camino, mas estres suma cada opcion (extraEstres).
//Los numeros son de ejemplo: ajustalos para balancear el juego.
//NUEVO: nombre = nombre de las imagenes en assets/textos (<nombre>_opcion.png y <nombre>_resultado.png).
//Si agregan o cambian una opcion, regeneren las imagenes con: python herramientas/generarTextos.py
object cargaDeOpciones {

  method cargar() {
    caminoFacil.agregarOpciones(self.opciones(0))
    caminoMedio.agregarOpciones(self.opciones(5))
    caminoDificil.agregarOpciones(self.opciones(10))
  }

  method opciones(extraEstres) = [
    new Opcion(nombre = "estudiarDeNoche", descripcion = "Estudiar toda la noche", resultado = "Sacaste 9, pero con ojeras", puntosAcademicos = 25, puntosEstres = 20 + extraEstres),
    new Opcion(nombre = "claseDeConsulta", descripcion = "Ir a la clase de consulta", resultado = "El profe te explicó todo", puntosAcademicos = 15, puntosEstres = 5 + extraEstres),
    new Opcion(nombre = "siesta", descripcion = "Dormir una siesta", resultado = "Te despertaste de noche", puntosAcademicos = 0, puntosEstres = -15 + extraEstres),
    new Opcion(nombre = "estudiarConAmigos", descripcion = "Estudiar con amigos", resultado = "Terminaron en la pizzería", puntosAcademicos = 10, puntosEstres = -5 + extraEstres),
    new Opcion(nombre = "tpEnGrupo", descripcion = "Hacer el TP en grupo", resultado = "Uno nunca contestó el grupo", puntosAcademicos = 20, puntosEstres = 10 + extraEstres),
    new Opcion(nombre = "tutorialYoutube", descripcion = "Ver un tutorial en YouTube", resultado = "Hasta que tuviste que aplicarlo", puntosAcademicos = 10, puntosEstres = 0 + extraEstres),
    new Opcion(nombre = "caminar", descripcion = "Salir a caminar", resultado = "Te despejaste un montón", puntosAcademicos = 0, puntosEstres = -20 + extraEstres),
    new Opcion(nombre = "entregarUltimoMomento", descripcion = "Entregar el TP a último momento", resultado = "Llegaste con 1 minuto de sobra", puntosAcademicos = 20, puntosEstres = 25 + extraEstres),
    new Opcion(nombre = "pedirApuntes", descripcion = "Pedir los apuntes a un compañero", resultado = "Dibujitos, pero algo sirvió", puntosAcademicos = 10, puntosEstres = 5 + extraEstres),
    new Opcion(nombre = "leerTeoria", descripcion = "Leer toda la teoría", resultado = "Entendiste la mitad", puntosAcademicos = 15, puntosEstres = 10 + extraEstres),
    new Opcion(nombre = "dormir8Horas", descripcion = "Dormir 8 horas", resultado = "Energía, pero sin tiempo", puntosAcademicos = 5, puntosEstres = -20 + extraEstres),
    new Opcion(nombre = "parcialSinEstudiar", descripcion = "Ir al parcial sin estudiar", resultado = "Zafaste de milagro", puntosAcademicos = 10, puntosEstres = 25 + extraEstres)
  ]
}
