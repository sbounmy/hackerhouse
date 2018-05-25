import React, { Component } from 'react';
import CardHouse from '../containers/card_house';
import BookingsPanel from './bookings_panel';
import CardMessages from '../containers/card_messages';
import {Card, Row, Col} from './bs';
import Intercom, { IntercomAPI } from 'react-intercom';
import Folder from './folder';
import _ from 'lodash';

export default props => {
  const isStaying = (props.user && props.house)

  if (!isStaying) {
    return ''
  }
  return (
    <Row>
      <Col lg="3">
        <CardHouse id={props.user.house_slug_id} />
        <BookingsPanel house_id={props.user.house_id} />
      </Col>
      <Col lg="9">
        <CardMessages user={props.user} house_id={props.user.house_id} />
        <Folder id={props.house.gdrive_folder_id} type='list'/>
      </Col>
    </Row>
  );
}