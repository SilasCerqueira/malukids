import 'dart:collection';
import 'package:conversor/rastreamento.dart';
import 'package:conversor/utils/currenteInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import 'correios.dart';


void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

CurrencyInputFormatter currencyInputFormatter = CurrencyInputFormatter();

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  double dolar = 4.08;
  double taxa = 0.00;
  int _numParcela = 0;
  String lastValue;
  var controller = new MoneyMaskedTextController(leftSymbol: 'R\$ ');
  String result =  'R\$ 0,00';

  var parcelas = <String>[
      'Débito (1.9%)',
      'Crédito - 1 Parcela (4.6%)',
      'Crédito - 2 Parcela (6.1%)',
      'Crédito - 3 Parcela (7.6%)',
      'Crédito - 4 Parcela (9.1%)',
      'Crédito - 5 Parcela (10.6%)',
      'Crédito - 6 Parcela (12.1%)',
      'Crédito - 7 Parcela (13.6%)',
      'Crédito - 8 Parcela (15.1%)',
      'Crédito - 9 Parcela (16.6%)',
      'Crédito - 10 Parcela (18.1%)',
      'Crédito - 11 Parcela (19.6%)',
      'Crédito - 12 Parcela (21.1%)',
    ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //main();
  }

  main() async{
    // Build out SOAP envelope, replace the string/int fields as appropriate.
    var envelope = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <AuthenticateCredential xmlns="http://foo.com/barr/320/Default">
              <nCdEmpresa></nCdEmpresa>
              <nCdEmpresa></nCdEmpresa>
              <nCdServico>04014,04510</nCdServico>
              <sCepOrigem>74355507</sCepOrigem>
              <sCepDestino>74934160</sCepDestino>
              <nVlPeso>3</nVlPeso>
              <nCdFormato>1</nCdFormato>
              <nVlComprimento>30</nVlComprimento>
              <nVlAltura>30</nVlAltura>
              <nVlLargura>30</nVlLargura>
              <sCdMaoPropria>N</sCdMaoPropria>
              <nVlValorDeclarado></nVlValorDeclarado>
              <sCdAvisoRecebimento>N</sCdAvisoRecebimento>
            </AuthenticateCredential>
          </soap:Body>
        </soap:Envelope>
        ''';

// Send the POST request, with full SOAP envelope as the request body.
    http.Response response = await http.post (
        'http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx?wsdl',
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          //'SOAPAction': 'AuthenticateCredential'
        },
        body: envelope
    );

// The server's response should be the raw XML output.
    var rawXmlResponse = response.body;

// Use the xml package's 'parse' method to parse the response.
    xml.XmlDocument parsedXml = xml.parse (rawXmlResponse);
    print(parsedXml);
  }

  void _calcularTaxa(String text){

    lastValue = text;
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double valor = currencyInputFormatter.getValorDouble();
    setState(() {
      switch (_numParcela)
      {
        case 0 :
          taxa = valor / ((100 - 1.9) / 100);
          break;
        case 1 :
          taxa =  valor / ((100  - 4.6) / 100);
          break;
        case 2 :
          taxa =  valor / ((100  - 6.1) / 100);
          break;
        case 3 :
          taxa =  valor / ((100  - 7.6) / 100);
          break;
        case 4 :
          taxa =  valor / ((100  - 9.1)  / 100);
          break;
        case 5 :
          taxa =  valor / ((100  - 10.6) / 100);
          break;
        case 6 :
          taxa =  valor / ((100  - 12.1) / 100);
          break;
        case 7 :
          taxa =  valor / ((100  - 13.6) / 100);
          break;
        case 8 :
          taxa =  valor / ((100  - 15.1) / 100);
          break;
        case 9 :
          taxa =  valor / ((100  - 16.6) / 100);
          break;
        case 10 :
          taxa =  valor / ((100  - 18.1) / 100);
          break;
        case 11 :
          taxa =  valor / ((100  - 19.6) / 100);
          break;
        case 12 :
          taxa =  valor / ((100  - 21.1) / 100);
          break;
        default :
          taxa = 0.00;
      }
      controller.updateValue(taxa);
      result = controller.text;
    });
  }

  void _clearAll(){
    realController.text = "";
    setState(() {
      taxa = 0.00;
      result = 'R\$ 0,00';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Calcular Taxa \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu Malu Kids'),
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
            ),
            ListTile(

              title: Text('Prazo e Valor Correios', style: TextStyle(fontSize: 18.0),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondRoute()),
                );
              },
            ),
            ListTile(
              title: Text('Rastreamento Correios', style: TextStyle(fontSize: 18.0),),
              onTap: () {
                //Navigator.push(
                 // context,
                //  MaterialPageRoute(builder: (context) => TreeRoute()),
                //);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                  buildTextField("R\$ 0,00","R\$", realController, _calcularTaxa, true, 30.0),
                  Divider(),
                  DropdownButton<String>(
                    style: TextStyle(
                        color: Colors.amber, fontSize: 25.0
                    ),
                    value: _numParcela == null ? null : parcelas[_numParcela],
                    items: parcelas.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _numParcela = parcelas.indexOf(value);
                        _calcularTaxa(lastValue);
                      });
                    },
                  ),
                  Divider(),
                  Text(
                    'Cliente Paga: $result',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 25.0 ),
                  ),
                ],
              ),
            ),
      );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController tec, Function func, bool enabled, double font ){
  return TextField(
      textAlign: TextAlign.center,
      enabled: enabled,
      controller: tec,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
      ),
      style: TextStyle(
        color: Colors.amber, fontSize: font
       ),
      onChanged: func,
      keyboardType: TextInputType.number,
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
        currencyInputFormatter
      ],
  );
}
