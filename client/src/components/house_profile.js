import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchHouse } from '../actions';

class HouseProfile extends Component {

  componentDidMount() {
    if (!this.props.house) {
      this.props.fetchHouse(this.props.user.house_slug_id);
    }
  }

  render() {
    const { house } = this.props;
    if (!house) {
      return ''
    }
    return (
      <div className="card d-md-block d-lg-block mb-4">
        <div className="card-body">
          <h6 className="mb-3">{house.name} <small>· <a href="#">RATP</a></small></h6>
          <ul className="list-unstyled list-spaced">
{/*            <li><span className="text-muted icon icon-calendar mr-3"></span>Went to <a href="#">Oh, Canada</a></li>
            <li><span className="text-muted icon icon-users mr-3"></span>Became friends with <a href="#">Obama</a></li>
            <li><span className="text-muted icon icon-github mr-3"></span>Worked at <a href="#">Github</a></li>*/}
            <li><span className="text-muted icon icon-home mr-3"></span>Lives in <a href="#">{house.address}</a></li>
            <li><span className="text-muted icon icon-location-pin mr-3"></span>From <a href="#">{house.zip_code} {house.city}</a></li>
            <li><span className="text-muted icon icon-users mr-3"></span>Hackers : <a href="#">{house.active_users} / {house.max_users}</a></li>
          </ul>
        </div>
      </div>
    )
  }
}


function mapStateToProps(state, nextProps) {
  return { user: state.session.user, house: state.houses[nextProps.id] };
}

export default connect(mapStateToProps, { fetchHouse })(HouseProfile);