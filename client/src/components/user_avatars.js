import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchUsers } from '../actions';
import _ from 'lodash';
import qs from 'query-string';

class UserAvatars extends Component {
  componentDidMount() {
    if (!_.isEmpty(this.props.ids)) {
      this.props.fetchUsers({'q[id.in]': this.props.ids});
    }
  }
  renderUser(user) {
    if (_.isNil(user)) {
      return ''
    }
    else {
      return <span><img title={user.firstname} className="rounded-circle" src={user.avatar_url} style={{'max-height': '20px'}}/></span>
    }
  }

  renderUsers() {
    const { users } = this.props;
    const { ids } = this.props;

    return _.map(ids, id => {
       return (<li className='list-inline-item'>{this.renderUser(users[id])}</li>)
    })
  }
  render() {
    return (<ul className='d-inline list-inline'>
      {this.renderUsers()}
    </ul>)
  }
}

function mapStateToProps(state) {
  return { users: state.user };
}

export default connect(mapStateToProps, { fetchUsers })(UserAvatars);