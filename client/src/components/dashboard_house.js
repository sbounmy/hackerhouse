import React, { Component } from 'react';
import HouseProfile from './house_profile';
import BookingsPanel from './bookings_panel';
import MessagesPanel from './messages_panel';
import {Row, Col} from './bs';
import Intercom, { IntercomAPI } from 'react-intercom';
import _ from 'lodash';

export default props => {
  const isStaying = (props.user && props.user.house_slug_id && props.user.check_out)

  if (!isStaying) {
    return ''
  }
  return (
    <Row>
      <Col lg="3">
        <HouseProfile id={props.user.house_slug_id} />
      </Col>
      <Col lg="6">
        <MessagesPanel house_id={props.user.house_id} />
        <BookingsPanel house_id={props.user.house_id} />
      </Col>
      <Col lg="3">
      </Col>
    </Row>
  );
}