import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import { destroySession } from '../actions';
import Profile from './profile';
import ActionsPanel from './actions_panel';
import Intercom, { IntercomAPI } from 'react-intercom';


class Dashboard extends Component {
  render() {
    const user = {
      user_id: this.props.user.id,
      email: this.props.user.email,
      name: `${this.props.user.firstname} ${this.props.user.lastname}`
    };
    return (
      <div className="row">
        <Intercom appID="az33rewf" { ...user } />
        <div className="col-lg-3">
          <Profile user={this.props.user}/>
        </div>
        <div className="col-lg-6">
          <ActionsPanel />
        </div>
      </div>
    );
  }
}

export default connect(null, { destroySession })(Dashboard);