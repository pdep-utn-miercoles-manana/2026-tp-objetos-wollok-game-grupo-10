import Caminos.*


object cargaDeOpciones {

  method cargar() {
    caminoFacil.agregarOpciones(self.opciones(0))
    caminoMedio.agregarOpciones(self.opciones(5))
    caminoDificil.agregarOpciones(self.opciones(10))
  }

  // Pozo de situaciones. Positivo = sube nivel academico / estres. Algunas bajan el academico (tentaciones e imprevistos).
  method opciones(extraEstres) = [
    new Opcion(nombre = "estudiarDeNoche", descripcion = "Estudiar toda la noche", resultado = "Sacaste un 9. Las ojeras llegaron hasta el piso.", puntosAcademicos = 25, puntosEstres = 20 + extraEstres),
    new Opcion(nombre = "maratonDeApuntes", descripcion = "Maratón de apuntes con mate", resultado = "Llegaste a la mitad. El mate, a cero.", puntosAcademicos = 20, puntosEstres = 15 + extraEstres),
    new Opcion(nombre = "resumenConColores", descripcion = "Armar un resumen con colores", resultado = "Quedó hermoso. Y encima lo entendiste.", puntosAcademicos = 15, puntosEstres = 5 + extraEstres),
    new Opcion(nombre = "claseDeConsulta", descripcion = "Ir a la clase de consulta", resultado = "El profe te explicó todo con paciencia.", puntosAcademicos = 15, puntosEstres = 5 + extraEstres),
    new Opcion(nombre = "resolverLaGuia", descripcion = "Resolver la guía de ejercicios", resultado = "Te trabaste en el 4, pero el resto salió.", puntosAcademicos = 18, puntosEstres = 10 + extraEstres),
    new Opcion(nombre = "tpEnGrupo", descripcion = "Hacer el TP en grupo", resultado = "Uno nunca contestó el grupo. Lo hiciste vos.", puntosAcademicos = 20, puntosEstres = 15 + extraEstres),
    new Opcion(nombre = "explicarleAUnCompa", descripcion = "Explicarle el tema a un compañero", resultado = "Al explicarlo, por fin lo entendiste vos.", puntosAcademicos = 15, puntosEstres = 0 + extraEstres),
    new Opcion(nombre = "leerTeoria", descripcion = "Leer toda la teoría", resultado = "Entendiste la mitad. La otra mitad, mañana.", puntosAcademicos = 15, puntosEstres = 10 + extraEstres),
    new Opcion(nombre = "repasarParcialesViejos", descripcion = "Repasar parciales viejos", resultado = "Cayó un ejercicio idéntico. Por fin, suerte.", puntosAcademicos = 20, puntosEstres = 8 + extraEstres),
    new Opcion(nombre = "bugALas3AM", descripcion = "Arreglar un bug a las 3 AM", resultado = "Era una llave sin cerrar. Otra vez.", puntosAcademicos = 12, puntosEstres = 20 + extraEstres),
    new Opcion(nombre = "tutorialYoutube", descripcion = "Ver un tutorial en YouTube", resultado = "Lo entendiste. Hasta que tuviste que aplicarlo.", puntosAcademicos = 10, puntosEstres = 0 + extraEstres),
    new Opcion(nombre = "pedirApuntes", descripcion = "Pedir los apuntes a un compañero", resultado = "Letra ilegible, pero algo sirvió.", puntosAcademicos = 10, puntosEstres = 5 + extraEstres),
    new Opcion(nombre = "entregarUltimoMomento", descripcion = "Entregar el TP a último momento", resultado = "Lo subiste a las 23:59. Respiraste recién a las 00:01.", puntosAcademicos = 20, puntosEstres = 25 + extraEstres),
    new Opcion(nombre = "parcialSinEstudiar", descripcion = "Ir al parcial sin estudiar", resultado = "Escribiste bien tu nombre. Ya es algo.", puntosAcademicos = 5, puntosEstres = 25 + extraEstres),
    new Opcion(nombre = "preguntarleAlProfe", descripcion = "Preguntarle una duda al profe", resultado = "Tardó 20 minutos en responder, pero valió la pena.", puntosAcademicos = 15, puntosEstres = 0 + extraEstres),
    new Opcion(nombre = "estudiarConAmigos", descripcion = "Estudiar con amigos", resultado = "Veinte minutos de estudio y tres horas de chisme.", puntosAcademicos = 5, puntosEstres = -10 + extraEstres),
    new Opcion(nombre = "siesta", descripcion = "Dormir una siestita", resultado = "Te despertaste de noche, sin ganas de nada.", puntosAcademicos = -5, puntosEstres = -15 + extraEstres),
    new Opcion(nombre = "unEpisodioDeNetflix", descripcion = "Un solo episodio de Netflix", resultado = "Eran las 5 AM y ya ibas por la temporada 3.", puntosAcademicos = -15, puntosEstres = -20 + extraEstres),
    new Opcion(nombre = "salirDeJoda", descripcion = "Salir de joda un ratito", resultado = "Volviste al mediodía. No te acordás nada.", puntosAcademicos = -20, puntosEstres = -25 + extraEstres),
    new Opcion(nombre = "tiktokCincoMinutos", descripcion = "Mirar TikTok cinco minutos", resultado = "Pasaron tres horas. No aprendiste nada.", puntosAcademicos = -10, puntosEstres = -10 + extraEstres),
    new Opcion(nombre = "unaPartidaRapida", descripcion = "Jugar una sola partida", resultado = "Son las 4 AM y vas por la sexta.", puntosAcademicos = -15, puntosEstres = -15 + extraEstres),
    new Opcion(nombre = "ordenarElEscritorio", descripcion = "Ordenar el escritorio antes de empezar", resultado = "Quedó impecable. Los apuntes, sin abrir.", puntosAcademicos = -10, puntosEstres = -5 + extraEstres),
    new Opcion(nombre = "mateConAmigos", descripcion = "Tomar unos mates con amigas", resultado = "Cuatro horas de charla sobre la vida.", puntosAcademicos = -10, puntosEstres = -15 + extraEstres),
    new Opcion(nombre = "faltarAClase", descripcion = "Faltar a clase, total hay apuntes", resultado = "Los apuntes eran del cuatrimestre pasado.", puntosAcademicos = -15, puntosEstres = -5 + extraEstres),
    new Opcion(nombre = "dormir8Horas", descripcion = "Dormir ocho horas de corrido", resultado = "Energía a full, pero perdiste toda la mañana.", puntosAcademicos = -5, puntosEstres = -20 + extraEstres),
    new Opcion(nombre = "irAlPartido", descripcion = "Ir a ver el partido", resultado = "Ganaron. Gritaste tanto que perdiste la voz.", puntosAcademicos = -10, puntosEstres = -20 + extraEstres),
    new Opcion(nombre = "mercadoLibre", descripcion = "Mirar cosas en Mercado Libre", resultado = "Compraste un teclado nuevo. De estudiar, nada.", puntosAcademicos = -10, puntosEstres = -5 + extraEstres),
    new Opcion(nombre = "caminar", descripcion = "Salir a caminar", resultado = "Te despejaste un montón. Y volviste con hambre.", puntosAcademicos = 0, puntosEstres = -20 + extraEstres),
    new Opcion(nombre = "respirarHondo", descripcion = "Hacer diez minutos de respiración", resultado = "Estás en paz. Aunque no sepas el tema.", puntosAcademicos = 0, puntosEstres = -25 + extraEstres),
    new Opcion(nombre = "gimnasio", descripcion = "Ir al gimnasio", resultado = "Te duele todo, pero la cabeza quedó limpia.", puntosAcademicos = -5, puntosEstres = -25 + extraEstres),
    new Opcion(nombre = "seCortoLaLuz", descripcion = "Se corta la luz en pleno estudio", resultado = "Sin luz, sin cargador y sin ganas.", puntosAcademicos = -10, puntosEstres = 15 + extraEstres),
    new Opcion(nombre = "cambiaronLaFecha", descripcion = "Cambian la fecha del parcial", resultado = "Ahora es mañana. Te enteraste anoche.", puntosAcademicos = -10, puntosEstres = 20 + extraEstres),
    new Opcion(nombre = "compuSinGuardar", descripcion = "Se te cuelga la compu", resultado = "El TP estaba sin guardar. Qué lindo día.", puntosAcademicos = -15, puntosEstres = 20 + extraEstres)
  ]
}
