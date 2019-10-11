
import 'package:conversor/utils/currenteInputFormatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SecondRoute extends StatefulWidget {
  @override
  _SecondRouteState createState() => _SecondRouteState();

}
class _SecondRouteState extends State<SecondRoute> {

  CurrencyInputFormatter currencyInputFormatter = CurrencyInputFormatter();
  final _cepDestinoController = new MaskedTextController(mask: '00.000-000');
  final _pesoController = new TextEditingController();
  final _valorController = TextEditingController();
  final _alturaController = TextEditingController();
  final _comprimentoController = TextEditingController();
  final _larguraController = TextEditingController();
  var _resposta = "";
  var _numSevico = 1;
  var _servicos = <String>[
    'PAC',
    'SEDEX',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _comprimentoController.text = "30";
    _larguraController.text = "30";
    _alturaController.text = "30";
    _valorController.text = "0";
    _resposta = "";
  }


  //teste
  void _callCorreiosRastreamento() async {

    var _servico = "";
    print(_numSevico);
    if(_numSevico == 0){
      _servico = "04510";
    }else{
      _servico = "04014";
    }
    final response = await http.post(
      "http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx"
          "?nCdEmpresa="
          "&sDsSenha="
          "&sCepOrigem=74355507"
          "&sCepDestino=" + _cepDestinoController.text.replaceAll(".", "").replaceAll("-", "") +
          "&nVlPeso=" + _pesoController.text +
          "&nCdFormato=1"
              "&nVlComprimento=" + _comprimentoController.text +
          "&nVlAltura=" + _alturaController.text +
          "&nVlLargura=" + _larguraController.text +
          "&sCdMaoPropria=n" +
          "&nVlValorDeclarado=" + _valorController.text +
          "&sCdAvisoRecebimento=n"
              "&nCdServico=" + _servico +
          "&nVlDiametro=0"
          "&StrRetorno=xml"
              "&nIndicaCalculo=0",
    );

    var bookshelfXml = response.body;
    var document = xml.parse(bookshelfXml);
    print(document.toXmlString(pretty: true, indent: '\t'));
    setState(() {
      var valor = document
          .findAllElements('Valor')
          .single
          .text;
      var prazoDeEntrega = document
          .findAllElements('PrazoEntrega')
          .single
          .text;
      var entregaSabado = document
          .findAllElements('EntregaSabado')
          .single
          .text;
      var entregaDomicilio = document
          .findAllElements('EntregaDomiciliar')
          .single
          .text;
      _resposta = "Valor: R\$$valor, Prazo de Entrega: $prazoDeEntrega" ;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _callCorreiosRastreamento();
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Prazo e Valor Correios"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _cepDestinoController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  labelText: "Cep Destino",
                  labelStyle: TextStyle(color: Colors.amber),
                  border: OutlineInputBorder(),
                  prefixText: "Cep Destino"
              ),
              style: TextStyle(
                  color: Colors.amber, fontSize: 18.0
              ),
              keyboardType: TextInputType.number,
            ),
            Divider(),
            TextField(
              controller: _pesoController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: "Peso(Kg)",
                labelStyle: TextStyle(color: Colors.amber),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                  color: Colors.amber, fontSize: 18.0
              ),
              keyboardType: TextInputType.number,
            ),
            Divider(),
            TextField(
              textAlign: TextAlign.center,
              controller: _valorController,
              decoration: InputDecoration(
                labelText: "Valor da Compra",
                labelStyle: TextStyle(color: Colors.amber),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                  color: Colors.amber, fontSize: 18.0
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
                currencyInputFormatter
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded( // wrap your Column in Expanded
                  child:  Container(
                      child: buildTextField("Largura", _larguraController)
                  ),
                ),
                Expanded( // wrap your Column in Expanded
                  child: Column(
                    children: <Widget>[
                      Container(
                          child: buildTextField("Altura", _alturaController)),
                    ],
                  ),
                ),
                Expanded( // wrap your Column in Expanded
                  child: Column(
                    children: <Widget>[
                      Container(child: buildTextField("Comprimento", _comprimentoController)),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            DropdownButton<String>(
              style: TextStyle(
                  color: Colors.amber, fontSize: 25.0
              ),
              value: _servicos[_numSevico],
              items: _servicos.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _numSevico = _servicos.indexOf(value);
                });
              },
            ),
            Divider(),
            Center(child: Text(_resposta,
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      textAlign: TextAlign.center,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
      ),
      style: TextStyle(
          color: Colors.amber, fontSize: 18
      ),
      keyboardType: TextInputType.number,
    );
  }
}