import 'package:flutter/material.dart';
import '../models/Voto.dart';
import 'SingoloVotoWid.dart';

class Votodisplay extends StatelessWidget {
  final Voto voto;
  final Voto? precedente;
  final int ms;
  final double grandezza;
  const  Votodisplay({super.key, required this.voto,  this.precedente,  required this.grandezza, required this.ms});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          VotoSingolo(voto: voto, prec: precedente, grandezza: grandezza, fontSize: 21, ms: ms,),
          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                voto.codiceMateria,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "${getData(voto.dataVoto)} | ${voto.nomeInteroMateria.length > 12 ? "${voto.nomeInteroMateria.substring(0, 12)}..." : voto.nomeInteroMateria}"
              )
            ],
          )

        ],
      )
    );
  }
  String getData(String dataString){
    List<String> nomiGiorni = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica',
    ];
    List<String> nomiMesi = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre',
    ];
    DateTime scadenza = DateTime.parse(dataString.substring(0, 10));
    DateTime scadenzaDateOnly = DateTime(
      scadenza.year,
      scadenza.month,
      scadenza.day,
    );

    String data = "${nomiGiorni[scadenzaDateOnly.weekday - 1].substring(0, 3)} "
        "${scadenzaDateOnly.day} ${nomiMesi[scadenzaDateOnly.month - 1].substring(0, 3)} "
        "${scadenzaDateOnly.year}";


    return data;
  }
}

