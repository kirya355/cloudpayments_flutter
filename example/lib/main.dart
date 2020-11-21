import 'package:cloudpayments_flutter_example/models/transaction.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cloudpayments_flutter/cloudpayments_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const MERCHANT_PUBLIC_ID = 'Your public id';
void main() {
  runApp(CardPaymentScreen());
}

class CardPaymentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CardPaymentScreenState();
  }
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  /*final cardHolderController = TextEditingController();*/
  final cardNumberMaskFormatter =
      MaskTextInputFormatter(mask: '#### #### #### ####');
  final expireDateFormatter = MaskTextInputFormatter(mask: '##/##');
  final cvcDateFormatter = MaskTextInputFormatter(mask: '###');
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isSaveCard = false;
  /*bool _isInvalidAsyncCardHolder = false;*/
  bool _isInvalidAsyncCardNumber = false;
  bool _isInvalidAsyncExpireDate = false;
  bool _isInvalidAsyncCvcCode = false;
  bool _isLoading = false;
  int errorDurationInSeconds = 3;
  void setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

/*  String _validateCardHolder(String cardHolder) {
    if (_isInvalidAsyncCardHolder) {
      _isInvalidAsyncCardHolder = false;
      return 'Card holder can\'t be blank';
    }
    return null;
  }*/

  String get _validateCardNumber {
    if (_isInvalidAsyncCardNumber) {
      Future.delayed(Duration(seconds: errorDurationInSeconds), () {
        setState(() {
          _isInvalidAsyncCardNumber = false;
        });
      });
      return 'Invalid card number';
    }
    return 'Card number';
  }

  String get _validateExpireDate {
    if (_isInvalidAsyncExpireDate) {
      Future.delayed(Duration(seconds: errorDurationInSeconds), () {
        setState(() {
          _isInvalidAsyncExpireDate = false;
        });
      });
      return 'Date invalid';
    }
    return 'MM/YY';
  }

  String _validateCvv() {
    if (_isInvalidAsyncCvcCode) {
      Future.delayed(Duration(seconds: errorDurationInSeconds), () {
        setState(() {
          _isInvalidAsyncCvcCode = false;
        });
      });
      return 'Incorrect code';
    }
    return 'CVC/CVV';
  }

  void _onPayClick() async {
    print('_onPayClick');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      FocusScope.of(context).unfocus();

/*      final cardHolder = cardHolderController.text;*/
      /* final isCardHolderValid = cardHolder.isNotEmpty;*/

      final cardNumber = cardNumberMaskFormatter.getUnmaskedText();
      final isValidCardNumber =
          await CloudpaymentsFlutter.isValidNumber(cardNumber);

      final expireDate = expireDateFormatter.getMaskedText();
      final isValidExpireDate =
          await CloudpaymentsFlutter.isValidExpireDate(expireDate);

      final cvcCode = cvcDateFormatter.getUnmaskedText();
      final isValidCvcCode = cvcCode.length == 3;

      cardNumberMaskFormatter.clear();
      /*  cardHolderController.clear();*/
      expireDateFormatter.clear();
      cvcDateFormatter.clear();
      _formKey.currentState.reset();
      /* if (!isCardHolderValid) {
        print('InvalidAsyncCardHolder');
        setState(() {
          _isInvalidAsyncCardHolder = true;
        });
      } else*/
      if (!isValidCardNumber) {
        print('InvalidAsyncCardNumber');
        setState(() {
          _isInvalidAsyncCardNumber = true;
        });
      } else if (!isValidExpireDate) {
        print('InvalidAsyncExpireDate');
        setState(() {
          _isInvalidAsyncExpireDate = true;
        });
      } else if (!isValidCvcCode) {
        print('InvalidAsyncCvcCode');
        setState(() {
          _isInvalidAsyncCvcCode = true;
        });
      } else {
        final cryptogram = await CloudpaymentsFlutter.cardCryptogram(
          cardNumber,
          expireDate,
          cvcCode,
          MERCHANT_PUBLIC_ID,
        );

        print(
            'Cryptogram = ${cryptogram.cryptogram}, Error = ${cryptogram.error}');

        if (cryptogram.cryptogram != null) {
          _auth(cryptogram.cryptogram, /*cardHolder*/ '', 1);
        }
      }
    }
  }

  void _auth(String cryptogram, String cardHolder, int amount) async {
    setLoading(true);

    /* try {
      final transaction = await api.auth(cryptogram, cardHolder, amount);
      setLoading(false);
      if (transaction.paReq != null && transaction.acsUrl != null) {
        _show3ds(transaction);
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(transaction.cardHolderMessage)));
      }
    } catch (e) {
      setLoading(false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error")));
    }*/
  }

  void _show3ds(Transaction transaction) async {
    final result = await CloudpaymentsFlutter.show3ds(
        transaction.acsUrl, transaction.transactionId, transaction.paReq);

    if (result != null) {
      if (result.success) {
        _post3ds(result.md, result.paRes);
      } else {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(result.error)));
      }
    }
  }

  void _post3ds(String md, String paRes) async {
    setLoading(true);
    /*   try {
      final transaction = await api.post3ds(md, paRes);
      setLoading(false);

      print(transaction);

      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(transaction.cardHolderMessage)));
    } catch (e) {
      setLoading(false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error")));
    }*/
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            height: 50,
            child: TextFormField(
              keyboardType: TextInputType.phone,
              inputFormatters: [cardNumberMaskFormatter],
              textInputAction: TextInputAction.next,
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(
                fontSize: 14,
              ),
              decoration: InputDecoration(
                  hintText: _validateCardNumber,
                  suffixIcon: Icon(
                    Icons.credit_card,
                    color: Color(0xFFA8A8A8),
                  ),
                  filled: true,
                  hintStyle: TextStyle(
                    color: _isInvalidAsyncCardNumber
                        ? Colors.red
                        : Color(0xFFA8A8A8),
                    fontSize: 14,
                  ),
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(4.5)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(4.5))),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlignVertical: TextAlignVertical.bottom,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [expireDateFormatter],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          hintText: _validateExpireDate,
                          filled: true,
                          hintStyle: TextStyle(
                            color: _isInvalidAsyncExpireDate
                                ? Colors.red
                                : Color(0xFFA8A8A8),
                            fontSize: 14,
                          ),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(4.5)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(4.5))),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'SF-Pro-Text',
                      ),
                      textAlignVertical: TextAlignVertical.bottom,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [cvcDateFormatter],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          hintText: _validateCvv(),
                          filled: true,
                          hintStyle: TextStyle(
                            color: Color(0xFFA8A8A8),
                            fontSize: 14,
                          ),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(4.5)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(4.5))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Divider(
            color: Colors.white,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Save card',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SF-Pro-Text',
                      fontSize: 14),
                ),
                Container(
                  height: 31,
                  child: Switch(
                    value: _isSaveCard,
                    onChanged: (bool value) {
                      setState(() {
                        _isSaveCard = !_isSaveCard;
                      });
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget confirmButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(23.0),
        ),
        onPressed: () {
          _onPayClick();
        },
        color: Colors.blue,
        child: Center(
          child: Text(
            'Pay',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      height: 66,
    );
  }

  Widget inputCard() {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(right: 10, left: 10, top: 20),
        height: 207,
        child: _form());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            'CloudPayments Example',
          ),
        ),
        body: inputCard(),
        bottomNavigationBar: confirmButton(),
      ),
    );
  }
}
