import React, { Component } from 'react';
import Profile from './profile';
import HouseProfile from './house_profile';
import CardStay from '../containers/card_stay';
import LinksPanel from './links_panel';
import PantryPanel from './pantry_panel';
import UserMessagesPanel from './user_messages_panel';
import { Col, Row } from './bs';
import _ from 'lodash';

export default props => {
  if (_.isNil(props.user)) {
    return ''
  }

  return (
    <Row>
      <Col lg="3">
        <Profile user={props.user}/>
        <HouseProfile id={props.user.house_id} />
      </Col>
      <Col lg="6">
        <CardStay />
        <UserMessagesPanel user={props.user} />
      </Col>
      <Col lg="3">
        <LinksPanel />
        <PantryPanel />
      </Col>
    </Row>
  );
}