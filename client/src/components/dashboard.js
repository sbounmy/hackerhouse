import React, { Component } from 'react';
import Profile from './profile';
import HouseProfile from './house_profile';
import CardUserMessages from './card_user_messages';
import CardStay from '../containers/card_stay';
import CardApply from '../containers/card_apply';
import CardLinks from './card_links';
import PantryPanel from './pantry_panel';

import { Col, Row } from './bs';
import _ from 'lodash';

export default props => {
  if (_.isNil(props.user)) {
    return ''
  }

  const { user } = props;
  const isStaying = !!(user && user.house_slug_id && user.check_out);

  return (
    <Row>
      <Col lg="3">
        <Profile user={user}/>
        <HouseProfile id={user.house_id} />
      </Col>
      <Col lg="6">
        {isStaying ? <CardStay /> : <CardApply/>}
        <CardUserMessages user={user} />
      </Col>
      <Col lg="3">
        <CardLinks />
        <PantryPanel />
      </Col>
    </Row>
  );
}