import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import { destroySession } from '../actions';

class Secret extends Component {
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
        <h3>Secret page!</h3>
        {this.renderNavLinks()}
      </div>
    );
  }
}

export default connect(null, { destroySession })(Secret);