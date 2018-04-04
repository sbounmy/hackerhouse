import React, { Component } from 'react';
import { connect } from 'react-redux';
import { IntercomAPI } from 'react-intercom';
import TrelloBoard from './trello_board';
import TypeForm from './typeform';
import { fetchBalance } from '../actions';
import { ReactTypeformEmbed } from 'react-typeform-embed';
import Moment from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

class ActionsPanel extends Component {
  constructor(props) {
    super(props);
    this.openForm = this.openForm.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchUserMessages(this.props.user.id);
    }
  }

  onSubmit(v) {
    console.log(v);
    return 'lol';
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

  renderAction(actions) {
    return _.map(actions, action => {
      return (
        <button type='button' className="btn btn-outline-primary btn-sm" onClick={() => IntercomAPI('showNewMessage', action.message)}>{action.name}</button>
      );
    });
  }

  renderStayActions() {
    const { user } = this.props;
    const staying = (user && user.house_slug_id && user.check_out)

    if (staying) {
      return (
         <div className="card mb-4 d-lg-block">
          <div className="card-body">
            <h6 className="mb-3">Séjour 😴</h6>
            <div data-grid="images" data-target-height="150">
              {/*<img className="media-object" data-width="640" data-height="640" data-action="zoom" src="assets/img/instagram_2.jpg" styles="width: 180px; height: 169px; margin-bottom: 10px; margin-right: 0px; display: inline-block; vertical-align: bottom;"/>*/}
            </div>
            <p>Tu continues l'aventure jusqu'au <strong><Moment format='DD MMMM YYYY'>{user.check_out}</Moment></strong></p>
            <p>Ma contribution solidaire du mois : {this.props.balance}€</p>
            <p className='text-right'>
              <button type='button'
              className="btn btn-link"
              onClick={() => IntercomAPI('showNewMessage', 'Hello la HackerHouse ✈️\nJe souhaite partir le :')}>
              Départ anticipé</button>
              <button type='button'
              className="btn btn-outline-primary"
              onClick={() => IntercomAPI('showNewMessage', 'Hello la HackerHouse 🤘\nJe souhaite prolonger mon séjour jusqu\'au ')}>
              Prolonger mon séjour</button>
            </p>
{/*              <ReactTypeformEmbed
                url={`https://hackerhouseparis.typeform.com/to/qmztfk?firstname=${user.firstname}&lastname=${user.lastname}&email=${user.email}`}
                hideHeader={true}
                popup={true}
                mode="drawer_right"
                autoOpen={this.neverApplied()}
                onSubmit={this.onSubmit}
                ref={(tf => this.typeformEmbed = tf)}/>*/}
          </div>
        </div>
      )
    }
    else {
      return (
        // hack for height as form
         <div className="card mb-4 d-lg-block">
          <div className="card-body">
            <h6 className="mb-3">Séjour 😴</h6>
            <div className='apply-popup'>
              <ReactTypeformEmbed
                url={`https://hackerhouseparis.typeform.com/to/qmztfk?firstname=${user.firstname}&lastname=${user.lastname}&email=${user.email}&user_id=${user.id}`}
                hideHeader={true}
                popup={true}
                mode="drawer_right"
                autoOpen={this.neverApplied()}
                onSubmit={this.onSubmit}
                ref={(tf => this.typeformEmbed = tf)}/>
            </div>
            <div data-grid="images" data-target-height="150">
            </div>
            <p>Viens vivre avec nous !</p>
            <button className="button btn btn-primary" onClick={this.openForm} style={{cursor: 'pointer'}}>Postuler maintenant !</button>
          </div>
        </div>
      );
    }
  }

  renderEventActions() {
     return (
      <div className="card mb-4 d-lg-block">
        <div className="card-body">
          <h6 className="mb-3">Mes meetups 🗣</h6>
          <div data-grid="images" data-target-height="150">
            {/*<img className="media-object" data-width="640" data-height="640" data-action="zoom" src="assets/img/instagram_2.jpg" styles="width: 180px; height: 169px; margin-bottom: 10px; margin-right: 0px; display: inline-block; vertical-align: bottom;"/>*/}
          </div>
          <p>Chaque semaine un meetup : https://www.meetup.com/HackerHouse-Paris</p>
          <p>MardX : de 19:00 à 20:30</p>
          <TypeForm id="f6Lzio" text="Organiser mon meetup 🎤"/>
        </div>
      </div>
    );
  }

  render() {
    return (
      <div>
      {this.renderStayActions()}
      {this.renderEventActions()}
      </div>
    );
  }
}

function mapStateToProps(state) {
  return { user: state.session.user, balance: state.balance.amount, userMessages: state.user.messages }
}

export default connect(mapStateToProps, { fetchBalance })(ActionsPanel);