import * as AmazonCognitoIdentity from 'amazon-cognito-identity-js';

const cognitoUserPoolIds = {
  UserPoolId: '****',
  Region: '****',
  ClientId: '****',
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(cognitoUserPoolIds);

// setup elm

const currentUser = userPool.getCurrentUser();

// @ts-ignore
const app = Elm.Main.init({
  node: document.getElementById('elm-app-is-loaded-here'),
  flags: { username: currentUser?.getUsername() ?? null },
});

// add port for signup
app.ports.signup.subscribe(function (data: {
  emailAddress: string;
  name: string;
  password: string;
}) {
  // callback for port - sign up
  console.log('data: ' + JSON.stringify(data));
  var attributeList = [];
  var dataEmail = {
    Name: 'email',
    Value: data.emailAddress,
  };
  var dataName = {
    Name: 'name',
    Value: data.name,
  };
  var attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail);
  attributeList.push(attributeEmail);
  var attributeName = new AmazonCognitoIdentity.CognitoUserAttribute(dataName);
  attributeList.push(attributeName);

  // start signup
  userPool.signUp(data.emailAddress, data.password, attributeList, [], function (err, result) {
    if (err) {
      var errorMessage = err.message || JSON.stringify(err);

      // send error to port
      app.ports.errors.send(errorMessage);
      return;
    } else {
      var cognitoUser = result?.user;
      if (cognitoUser) {
        app.ports.signupSuccess.send({ username: cognitoUser.getUsername() });
      } else {
        app.ports.errors.send('No user response');
      }
    }
  });
});

// add port for login
app.ports.login.subscribe(function (data: { emailAddress: string; password: string }) {
  console.log('data: ' + JSON.stringify(data));

  var authenticationData = {
    Username: data.emailAddress,
    Password: data.password,
  };

  const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);

  var userData = {
    Username: data.emailAddress,
    Pool: userPool,
  };
  var cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

  // login user
  cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: function (result) {
      console.log(result);
      // send success to port
      const user = userPool.getCurrentUser();
      app.ports.loginSuccess.send(user?.getUsername() ?? 'please refresh page');
    },
    onFailure: function (err) {
      var errorMessage = err.message || JSON.stringify(err);
      // send error to port
      app.ports.errors.send(errorMessage);
    },
  });
});

app.ports.logout.subscribe(() => {
  userPool.getCurrentUser()?.signOut();
});
