import React, { Component } from 'react';
import { IntercomAPI } from 'react-intercom';
import _ from 'lodash';

export default class ActionsPanel extends Component {
  renderAction(actions) {
    return _.map(actions, action => {
      return (
        <button className="btn btn-outline-primary btn-sm" onClick={() => IntercomAPI('showNewMessage', action.message)}>{action.name}</button>
      );
    });
  }

  renderActions(title, actions) {
    return (
       <div className="card mb-4 d-lg-block">
        <div className="card-body">
          <h6 className="mb-3">{title}</h6>
          <div data-grid="images" data-target-height="150">
            {/*<img className="media-object" data-width="640" data-height="640" data-action="zoom" src="assets/img/instagram_2.jpg" styles="width: 180px; height: 169px; margin-bottom: 10px; margin-right: 0px; display: inline-block; vertical-align: bottom;"/>*/}
          </div>
          {/*<p><strong>It might be time to visit Iceland.</strong> Iceland is so chill, and everything looks cool here. Also, we heard the people are pretty nice. What are you waiting for?</p>*/}
          {this.renderAction(actions)}
        </div>
      </div>
    )
  }

  render() {
    return (
      <div>
      {this.renderActions('Séjour 😴', [{ name: 'Départ anticipé', message: 'Hello la HackerHouse\nJe souhaite partir le :' },
                                    { name: 'Prolonger mon séjour', message: 'Hello la HackerHouse\nJe souhaite prolonger mon séjour jusqu\'au' }
                                   ])}
      {this.renderActions('Docteur Bread 🍞', [{ name: 'Annuler mon abonnement', message: 'Hello la HackerHouse\nJe ne souhaite pas manger la semaine du ' },
                                              { name: 'Reprendre mon abonnement', message: 'Hello la HackerHouse\nJe souhaite manger docteur bread la semaine du' }
                                              ])}
      </div>
    );
  }
}