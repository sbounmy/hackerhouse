import React, { Component } from 'react';
import { connect } from 'react-redux';
import { createSession } from '../actions';
import { Link } from 'react-router-dom';
import { Field, reduxForm } from 'redux-form';
import { destroySession } from '../actions';

class Home extends Component {

  componentDidMount() {
    if (!this.props.user) {
      this.props.history.push('/sessions/new')
    }
  }

  renderNavLinks() {
    if (this.props.user) {
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
      </div>
    );
  }
}

function mapStateToProps({session: { user }}) {
  return { user }
}

export default connect(mapStateToProps, { destroySession })(Home);