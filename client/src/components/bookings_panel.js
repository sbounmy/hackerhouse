import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchActiveOrUpcomingUsers } from '../actions';
import Moment from 'react-moment';
import 'moment/locale/fr';
import FriendlyName from './friendly_name';
import _ from 'lodash';

class BookingsPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchActiveOrUpcomingUsers(this.props.user.house_id);
    }
  }

  badge(action, date) {
    if (action == 'check_out') {
      return <span className='badge badge-warning text-right'>✈️ Départ <Moment locale="fr" fromNow>
              {date}
            </Moment></span>
    } else {
      return <span className='badge badge-success text-right'>✅ Arrivée <Moment locale="fr" fromNow>
              {date}
            </Moment></span>
    }
  }

  toggleShowAll(e){
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      showAll: !this.state.showAll
    })
  }

  toggleText() {
    return this.state.showAll ? 'Aucun autre arrivée / départ' : 'Voir tous les prochains départs / arrivées'
  }

  optionalClassName(index) {
    if (index > 2 && !this.state.showAll) {
      return 'd-none'
    }
  }

  renderUsers() {
    return _.map(this.props.active_or_upcoming_users, (user, index) => {
      return (
        <li className={`border rounded my-3 px-3 py-2 ${this.optionalClassName(index)}`} key={index}>
          <div className='d-flex flex-row justify-content-between align-items-start'>
            <h6 className="d-block mt-0 mb-1">
            {this.badge(user.action, user.action_date)}
            </h6>
            <Moment locale="fr" format='DD/MM'>
                  {user.action_date}
            </Moment>
          </div>
          <div className='d-flex flex-row justify-content-between'>
            <div className='text-truncate'>
              <strong><FriendlyName firstname={user.firstname} lastname={user.lastname} /></strong><i>, {user.bio_title}</i>
            </div>
            <div><img className="ml-2 rounded-circle" src={user.avatar_url} style={{'max-height': '20px'}}/></div>
          </div>
        </li>
      )
    });
  }

  render() {
    const staying = (this.props.user && this.props.user.house_slug_id && this.props.user.check_out)

    if (staying) {
      return (
         <div className="card mb-4 d-lg-block">
          <div className="card-body">
            <div className="d-flex flex-row justify-content-between align-items-start">
              <h6 className="mb-3">Mes colocs</h6>
              <a className=""
                 href="https://drive.google.com/drive/folders/1CLU7iON-CSUNud5i_b1nI1LBbnF83_gl?usp=sharing"
                 target="_blank">Trouver un nouveau 🤙</a>
            </div>
            <ul className='list-unstyled'>
              {this.renderUsers()}
              <li>
                <p className="text-center">
                  <a href="#" onClick={this.toggleShowAll}>{this.toggleText()}</a>
                </p>
              </li>
            </ul>
          </div>
        </div>
      )
    } else {
      return ''
    }
  }
}

function mapStateToProps(state) {
  return { user: state.session.user, active_or_upcoming_users: state.user.active_or_upcoming_users}
}

export default connect(mapStateToProps, { fetchActiveOrUpcomingUsers })(BookingsPanel);