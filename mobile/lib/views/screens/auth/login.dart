import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dreamshare/util/animations.dart';
import 'package:dreamshare/util/const.dart';
import 'package:dreamshare/util/enum.dart';
import 'package:dreamshare/util/router.dart';
import 'package:dreamshare/util/validations.dart';
import 'package:dreamshare/views/screens/main_screen.dart';
import 'package:dreamshare/views/widgets/custom_button.dart';
import 'package:dreamshare/views/widgets/custom_text_field.dart';
import 'package:dreamshare/util/extensions.dart';
import 'package:dreamshare/services/auth_service.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;
  bool validate = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String email = '', password = '', name = '', username = '';
  FocusNode nameFN = FocusNode();
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  FormMode formMode = FormMode.LOGIN;
  final AuthService _authService = AuthService();

  Future<void> login() async {
    FormState form = formKey.currentState!;
    form.save();

    if (!form.validate()) {
      validate = true;
      setState(() {});
      return;
    }

    setState(() => loading = true);

    try {
      if (formMode == FormMode.LOGIN) {
        await _authService.login(email, password);
      } else if (formMode == FormMode.REGISTER) {
        await _authService.register(
          email: email,
          nomeUsuario: username,
          nomeCompleto: name,
          password: password,
        );
      }
      if (mounted) {
        Navigate.pushPageReplacement(context, MainScreen());
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Row(
          children: [
            buildLottieContainer(),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: buildFormContainer(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildLottieContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      width: screenWidth < 700 ? 0 : screenWidth * 0.5,
      duration: Duration(milliseconds: 500),
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      child: Center(
        child: Lottie.asset(
          AppAnimations.chatAnimation,
          height: 400,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  buildFormContainer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '${Constants.appName}',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ).fadeInList(0, false),
        SizedBox(height: 10),
        Text(
          'Compartilhe seus sonhos ✨',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: 50.0),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: formKey,
          child: buildForm(),
        ),
        Visibility(
          visible: formMode == FormMode.LOGIN,
          child: Column(
            children: [
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    formMode = FormMode.FORGOT_PASSWORD;
                    setState(() {});
                  },
                  child: Text('Esqueceu a senha?'),
                ),
              ),
            ],
          ),
        ).fadeInList(3, false),
        SizedBox(height: 20.0),
        buildButton(),
        Visibility(
          visible: formMode == FormMode.LOGIN,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Não tem uma conta?'),
              TextButton(
                onPressed: () {
                  formMode = FormMode.REGISTER;
                  setState(() {});
                },
                child: Text('Cadastre-se'),
              ),
            ],
          ),
        ).fadeInList(5, false),
        Visibility(
          visible: formMode != FormMode.LOGIN,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Já tem uma conta?'),
              TextButton(
                onPressed: () {
                  formMode = FormMode.LOGIN;
                  setState(() {});
                },
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: formMode == FormMode.REGISTER,
          child: Column(
            children: [
              CustomTextField(
                enabled: !loading,
                hintText: "Nome completo",
                textInputAction: TextInputAction.next,
                validateFunction: Validations.validateName,
                onSaved: (String? val) {
                  name = val ?? '';
                },
                focusNode: nameFN,
                nextFocusNode: usernameFN,
              ),
              SizedBox(height: 20.0),
              CustomTextField(
                enabled: !loading,
                hintText: "Nome de usuário",
                textInputAction: TextInputAction.next,
                validateFunction: Validations.validateName,
                onSaved: (String? val) {
                  username = val ?? '';
                },
                focusNode: usernameFN,
                nextFocusNode: emailFN,
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
        CustomTextField(
          enabled: !loading,
          hintText: "Email",
          textInputAction: TextInputAction.next,
          validateFunction: Validations.validateEmail,
          onSaved: (String? val) {
            email = val ?? '';
          },
          focusNode: emailFN,
          nextFocusNode: passFN,
        ).fadeInList(1, false),
        Visibility(
          visible: formMode != FormMode.FORGOT_PASSWORD,
          child: Column(
            children: [
              SizedBox(height: 20.0),
              CustomTextField(
                enabled: !loading,
                hintText: "Senha",
                textInputAction: TextInputAction.done,
                validateFunction: Validations.validatePassword,
                submitAction: login,
                obscureText: true,
                onSaved: (String? val) {
                  password = val ?? '';
                },
                focusNode: passFN,
              ),
            ],
          ),
        ).fadeInList(2, false),
      ],
    );
  }

  buildButton() {
    return loading
        ? Center(child: CircularProgressIndicator())
        : CustomButton(
            label: formMode == FormMode.LOGIN
                ? "Entrar"
                : formMode == FormMode.REGISTER
                    ? "Cadastrar"
                    : "Enviar",
            onPressed: () => login(),
          ).fadeInList(4, false);
  }
}
