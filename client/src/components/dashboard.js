import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import { destroySession } from '../actions';
import Profile from './profile';
import HouseProfile from './house_profile';
import ActionsPanel from './actions_panel';
import LinksPanel from './links_panel';
import PantryPanel from './pantry_panel';
import BookingsPanel from './bookings_panel';
import MessagesPanel from './messages_panel';
import Intercom, { IntercomAPI } from 'react-intercom';
import _ from 'lodash';

class Dashboard extends Component {
  render() {
    if (_.isNil(this.props.user)) {
      return ''
    }

    const user = {
      user_id: this.props.user.id,
      email: this.props.user.email,
      name: `${this.props.user.firstname} ${this.props.user.lastname}`
    };
    return (
      <div className='row'>
        <Intercom appID="fhj2ew9z" { ...user } />
        <div className="col-lg-3">
          <Profile user={this.props.user}/>
          <HouseProfile id={this.props.user.house_slug_id} />
        </div>
        <div className="col-lg-6">
          <ActionsPanel />
          <MessagesPanel house_id={this.props.user.house_id} />
          <BookingsPanel house_id={this.props.user.house_id} />
        </div>
        <div className="col-lg-3">
          <LinksPanel />
          <PantryPanel />
        </div>
      </div>
    );
  }
}

export default connect(null, { destroySession })(Dashboard);