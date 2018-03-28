import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchActiveOrUpcomingUsers } from '../actions';
import Moment from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

class BookingsPanel extends Component {
  componentDidMount() {
    if (this.props.user) {
      this.props.fetchActiveOrUpcomingUsers(this.props.user.house_id);
    }
  }

  badge(action) {
    if (action == 'check_out') {
      return <span className='badge badge-warning text-right'>Départ ✈️</span>
    } else {
      return <span className='badge badge-success text-right'>Arrivée ✅</span>
    }
  }

  renderUsers() {
    return _.map(this.props.active_or_upcoming_users, (user) => {
      return (
        <li className='border rounded my-3 px-3 py-2' key={user.action_date}>
          <div className='d-flex flex-row justify-content-between align-items-start'>
            <h5 className="d-block mt-0 mb-1">
            <Moment locale="fr" format='dddd D MMMM'>
                  {user.action_date}
            </Moment>
            </h5>
            {this.badge(user.action)}
          </div>
          <div className='d-flex flex-row justify-content-between'>
            <div className='text-truncate'>
              <strong>{user.firstname} {user.lastname}</strong><i>, {user.bio_title}</i>
            </div>
            <div><img className="ml-2 rounded-circle" src={user.avatar_url} style={{'max-height': '20px'}}/></div>
          </div>
        </li>
      )
    });
  }

  render() {
    if (!this.props.user) {
      return ''
    }
    return (
      <div>
        <div className="d-flex flex-row justify-content-between align-items-start">
          <h6 className="mb-3">Réservations</h6>
          <a className=""
             href="https://drive.google.com/drive/folders/1CLU7iON-CSUNud5i_b1nI1LBbnF83_gl?usp=sharing"
             target="_blank">Trouver un nouveau coloc 🤙</a>
        </div>
        <ul className='list-unstyled'>{this.renderUsers()}
        <li><p className="text-center">Aucun autre arrivée / départ</p></li>
        </ul>
      </div>
    );
  }
}

function mapStateToProps(state) {
  return { user: state.session.user, active_or_upcoming_users: state.user.active_or_upcoming_users}
}

export default connect(mapStateToProps, { fetchActiveOrUpcomingUsers })(BookingsPanel);