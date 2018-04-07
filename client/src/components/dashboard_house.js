import React, { Component } from 'react';
import CardHouse from '../containers/card_house';
import BookingsPanel from './bookings_panel';
import CardMessages from '../containers/card_messages';
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
        <CardHouse id={props.user.house_slug_id} />
      </Col>
      <Col lg="6">
        <CardMessages house_id={props.user.house_id} />
        <BookingsPanel house_id={props.user.house_id} />
      </Col>
      <Col lg="3">
      </Col>
    </Row>
  );
}