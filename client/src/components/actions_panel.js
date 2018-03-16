import React, { Component } from 'react';
import { connect } from 'react-redux';
import { IntercomAPI } from 'react-intercom';
import TrelloBoard from './trello_board';
import TypeForm from './typeform';
import { fetchBalance } from '../actions';
import { ReactTypeformEmbed } from 'react-typeform-embed';

import _ from 'lodash';

class ActionsPanel extends Component {
  constructor(props) {
    super(props);
    this.openForm = this.openForm.bind(this);
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
    const staying = (this.props.user && this.props.user.house_slug_id && this.props.user.check_out)

    if (staying) {
      return (
         <div className="card mb-4 d-lg-block">
          <div className="card-body">
            <h6 className="mb-3">Séjour 😴</h6>
            <div data-grid="images" data-target-height="150">
              {/*<img className="media-object" data-width="640" data-height="640" data-action="zoom" src="assets/img/instagram_2.jpg" styles="width: 180px; height: 169px; margin-bottom: 10px; margin-right: 0px; display: inline-block; vertical-align: bottom;"/>*/}
            </div>
            <p>{`Tu continues l'aventure jusqu'au ${this.props.user.check_out}`}</p>
            <p>Ma contribution solidaire du mois : {this.props.balance}€</p>
            {this.renderAction([{ name: 'Départ anticipé', message: 'Hello la HackerHouse ✈️\nJe souhaite partir le :' },
                                { name: 'Prolonger mon séjour', message: 'Hello la HackerHouse 🤘\nJe souhaite prolonger mon séjour jusqu\'au ' }
                               ])}
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
            <div class='apply-popup'>
              <ReactTypeformEmbed url={'https://hackerhouseparis.typeform.com/to/qmztfk'}
                    hideHeader={true}
                    popup={true}
                    mode="drawer_right"
                    autoOpen={true}
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

  renderFoodActions() {
     return (
      <div className="card mb-4 d-lg-block">
        <div className="card-body">
          <h6 className="mb-3">Docteur Bread 🍞</h6>
          <div data-grid="images" data-target-height="150">
            {/*<img className="media-object" data-width="640" data-height="640" data-action="zoom" src="assets/img/instagram_2.jpg" styles="width: 180px; height: 169px; margin-bottom: 10px; margin-right: 0px; display: inline-block; vertical-align: bottom;"/>*/}
          </div>
          <p>5 diners / semaine pour 30€</p>
          {this.renderAction([{ name: 'Annuler mon abonnement', message: 'Hello la HackerHouse\nJe ne souhaite pas manger la semaine du ' },
                                                { name: 'Reprendre mon abonnement', message: 'Hello la HackerHouse\nJe souhaite manger docteur bread la semaine du ' }
                                                ])}
          <TrelloBoard id='BTT7m0B4'/>
        </div>
      </div>
    );
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
  return { user: state.session.user, balance: state.balance.amount }
}

export default connect(mapStateToProps, { fetchBalance })(ActionsPanel);