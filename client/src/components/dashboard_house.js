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

class DashboardHouse extends Component {
  render() {
    const isStaying = (this.props.user && this.props.user.house_slug_id && this.props.user.check_out)

    if (!isStaying) {
      return ''
    }
    return (
      <div className='row'>
        <div className="col-lg-3">
          <HouseProfile id={this.props.user.house_slug_id} />
        </div>
        <div className="col-lg-6">
          <MessagesPanel house_id={this.props.user.house_id} />
          <BookingsPanel house_id={this.props.user.house_id} />
        </div>
        <div className="col-lg-3">
        </div>
      </div>
    );
  }
}

export default connect(null, { destroySession })(DashboardHouse);