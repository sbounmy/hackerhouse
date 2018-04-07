import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Card, Button } from '../components/bs';
import { fetchBalance } from '../actions';
import { ReactTypeformEmbed } from 'react-typeform-embed';
import Moment from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

class CardStay extends Component {
  constructor(props) {
    super(props);
    this.openForm = this.openForm.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchUserMessages(this.props.user.id);
    }
  }

  // return false when already applied
  // return true otherwise
  // should have a boolean flag on API
  neverApplied() {
    return _.isEmpty(this.props.userMessages);
  }

  openForm() {
    this.typeformEmbed.typeform.open();
  }

  componentDidMount() {
    if (this.props.user && this.props.user.house_slug_id) {
      this.props.fetchBalance(this.props.user.house_slug_id, this.props.user.id);
    }
  }

  renderStay(user) {
    return(
      <div>
        <p>Tu continues l'aventure jusqu'au <strong><Moment format='DD MMMM YYYY'>{user.check_out}</Moment></strong></p>
        <p>Ma contribution solidaire du mois : {this.props.balance}€</p>
        <p className='text-right'>
          <Button type='link'
                  message={'Hello la HackerHouse ✈️\nJe souhaite partir le : '}>
          Départ anticipé</Button>
          <Button type='outline-primary'
                  message={'Hello la HackerHouse 🤘\nJe souhaite prolonger mon séjour jusqu\'au '}>
          Prolonger mon séjour</Button>
        </p>
      </div>
    )
  }

  renderApply(user) {
    return (
      <div>
        <div className='apply-popup'>
          <ReactTypeformEmbed
            url={`https://hackerhouseparis.typeform.com/to/qmztfk?firstname=${user.firstname}&lastname=${user.lastname}&email=${user.email}&user_id=${user.id}`}
            hideHeader={true}
            popup={true}
            mode="drawer_right"
            autoOpen={this.neverApplied()}
            ref={(tf => this.typeformEmbed = tf)}/>
        </div>
        <p>Viens vivre avec nous !</p>
        <Button type='primary'
                onClick={this.openForm}>
                  Postuler maintenant !
        </Button>
        {/*<button className="button btn btn-primary" onClick={this.openForm} style={{cursor: 'pointer'}}>Postuler maintenant !</button>*/}
      </div>
    )
  }

  isStaying() {
    const { user } = this.props;
    return user && user.house_slug_id && user.check_out
  }

  render() {
    return (
      <Card className='mb-4 d-lg-block'
            title="Séjour 😴">
        {this.isStaying() ? this.renderStay(this.props.user) : this.renderApply(this.props.user)}
      </Card>
    );
  }
}

function mapStateToProps(state) {
  return { user: state.session.user, balance: state.balance.amount, userMessages: state.user.messages }
}

export default connect(mapStateToProps, { fetchBalance })(CardStay);