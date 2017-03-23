import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {
  render() {
    return (
      <UserTable />
    );
  }
}

class UserCol extends React.Component {
  render() {
    return (<div className="col sqs-col-2 span-2">
      <div className="sqs-block-content">
        <div className="center">
          <img className="avatar xs" src={this.props.user.avatarUrl} />
          <p>
            <strong>{this.props.user.firstname}</strong><br /><small>{this.props.user.title}</small>
          </p>
        </div>
      </div>
    </div>
    );
  }
}

class UserTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      users: [],
    };
  }

  componentDidMount() {
    this.fetchUsers().then(response => {
      this.setState({
        users: response
      });
    });
  }

  fetchUsers() {
    const camelize = function(str) {
    return str
        .replace(/(?:\s|_)(.)/g, function($1) { return $1.toUpperCase(); })
        .replace(/(?:\s|_)/g, '')
        .replace(/^(.)/, function($1) { return $1.toLowerCase(); });
    }

    const camelizeObject = function(obj) {
      obj.forEach(u => {
        var attrName;
        for (attrName in u) {
          u[camelize(attrName)] = u[attrName]
          if (camelize(attrName) != attrName) {
            delete u[attrName]
          }
        }
      })
      return obj;
    }

    return fetch('/v1/users?q[active]=1').then(response => {
      return response.json();
    }).then(json => {
      return camelizeObject(json);
    });
  }

  render() {
    var cols = [];
    this.state.users.forEach(function(user) {
      cols.push(<UserCol user={user} />);
    });
    return (
      <div className="row sqs-row">
        {cols}
      </div>
    );
  }
}

export default App;
