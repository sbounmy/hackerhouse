import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Card, Button } from '../components/bs';
import { fetchBalance } from '../actions';
import Moment from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

class CardStay extends Component {
  componentDidMount() {
    if (this.props.user && this.props.user.house_slug_id) {
      this.props.fetchBalance(this.props.user.house_slug_id, this.props.user.id);
    }
  }

  render() {
    const { user, balance } = this.props;

    return (
      <Card className='mb-4 d-lg-block'
            title="Séjour 😴">
        <p>Tu continues l'aventure jusqu'au <strong><Moment format='DD MMMM YYYY'>{user.check_out}</Moment></strong></p>
        <p>Ma contribution solidaire du mois : {balance}€</p>
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
  return { user: state.session.user, balance: state.balance.amount }
}

export default connect(mapStateToProps, { fetchBalance })(CardStay);