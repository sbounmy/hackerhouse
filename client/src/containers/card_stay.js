import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Card, Button } from '../components/bs';
import CardMonthStay from './card_month_stay';
import Moment, { moment } from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

class CardStay extends Component {
  render() {
    const { user, amounts } = this.props;

    return (
      <Card className='mb-4 d-lg-block'
            title="Séjour 😴">
        <p>Tu continues l'aventure jusqu'au <strong><Moment format='DD MMMM YYYY'>{user.check_out}</Moment></strong></p>
        <h5>Contribution solidaire</h5>
        <div className="card-group">
          <CardMonthStay fromNow={0} />
          <CardMonthStay fromNow={1} />
          <CardMonthStay fromNow={2} />
        </div>
        <p className='text-right'>
          <Button type='link'
                  message={'Hello la HackerHouse ✈️\nJe souhaite partir le : '}>
          Départ anticipé</Button>
          <Button type='outline-primary'
                  message={'Hello la HackerHouse 🤘\nJe souhaite prolonger mon séjour jusqu\'au '}>
          Prolonger mon séjour</Button>
        </p>
      </Card>
    );
  }
}

function mapStateToProps(state) {
  return { user: state.session.user }
}

export default connect(mapStateToProps, {})(CardStay);