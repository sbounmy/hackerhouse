import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createSession } from '../actions';
import { Link } from 'react-router-dom';
import { Field, reduxForm } from 'redux-form';
import { destroySession } from '../actions';

class Home extends Component {
  logoutOnClick() {
    this.props.destroySession(this.props.history);
  }

  renderNavLinks() {
    if (this.props.authenticated) {
      return (
        <div>
          <h3>Welcome {this.props.user.firstname},</h3>
          <button
          onClick={this.logoutOnClick.bind(this)}>
            Logout
          </button>
        </div>
      );
    } else {
      return (
        <Link to="/sessions/new">
          Se connecter
        </Link>
      );
    }
  }
  render() {
    return (
      <div>
        <h3>Welcome!</h3>
        {this.renderNavLinks()}
      </div>
    );
  }
}

function mapStateToProps({session}) {
  return { authenticated: session.authenticated, user: session.user }
}

export default connect(mapStateToProps, { destroySession })(Home);