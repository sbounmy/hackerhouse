import React, { Component } from 'react';
import { connect } from 'react-redux';
import { IntercomAPI } from 'react-intercom';
import TrelloBoard from './trello_board';
import TypeForm from './typeform';

import _ from 'lodash';

class ActionsPanel extends Component {
  renderAction(actions) {
    return _.map(actions, action => {
      return (
        <button type='button' className="btn btn-outline-primary btn-sm" onClick={() => IntercomAPI('showNewMessage', action.message)}>{action.name}</button>
      );
    });
  }

  renderStayActions() {
    const content = (this.props.user && this.props.user.check_out) ? `Tu continues l'aventure jusqu'au ${this.props.user.check_out}` : 'Viens vivre avec nous !'

    return (
       <div className="card mb-4 d-lg-block">
        <div className="card-body">
          <h6 className="mb-3">Séjour 😴</h6>
          <div data-grid="images" data-target-height="150">
            {/*<img className="media-object" data-width="640" data-height="640" data-action="zoom" src="assets/img/instagram_2.jpg" styles="width: 180px; height: 169px; margin-bottom: 10px; margin-right: 0px; display: inline-block; vertical-align: bottom;"/>*/}
          </div>
          <p>{content}</p>
          {this.renderAction([{ name: 'Départ anticipé', message: 'Hello la HackerHouse ✈️\nJe souhaite partir le :' },
                                    { name: 'Prolonger mon séjour', message: 'Hello la HackerHouse 🤘\nJe souhaite prolonger mon séjour jusqu\'au ' }
                                   ])}
        </div>
      </div>
    );
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
      {this.renderEventActions()}
      {this.renderStayActions()}
      {this.renderFoodActions()}
      </div>
    );
  }
}

function mapStateToProps({session: {user}}) {
  return { user }
}

export default connect(mapStateToProps, { })(ActionsPanel);