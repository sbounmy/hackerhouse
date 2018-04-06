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
import UserMessagesPanel from './user_messages_panel';
import Intercom, { IntercomAPI } from 'react-intercom';
import { Col, Row } from './bs';
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
      <Row>
        <Intercom appID={process.env.REACT_APP_INTERCOM_APP_ID} { ...user } />
        <Col lg="3">
          <Profile user={this.props.user}/>
          <HouseProfile id={this.props.user.house_id} />
        </Col>
        <Col lg="6">
          <ActionsPanel />
          <UserMessagesPanel user={this.props.user} />
        </Col>
        <Col lg="3">
          <LinksPanel />
          <PantryPanel />
        </Col>
      </Row>
    );
  }
}

export default connect(null, { destroySession })(Dashboard);