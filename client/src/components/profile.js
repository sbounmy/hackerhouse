import React, { Component } from 'react';
import { connect } from 'react-redux';

class Profile extends Component {
  cardHeaderStyle() {
    var { house_slug_id } = this.props.user;
    if (house_slug_id == null)
      house_slug_id = 'default';

    return {
      'background-image': `url(img/${house_slug_id}.jpg)`
    }
  }

  render() {
    const { user } = this.props;
    return (
      <div className="mb-4 card card-profile">
        <div className="card-header" style={this.cardHeaderStyle()}></div>
        <div className="card-body text-xs-center">
          <img className="card-profile-img" src={user.avatar_url}/>
          <h5 className="card-title">{user.firstname}</h5>
          <p className="mb-4">{user.bio_title}</p>
{/*          <button className="btn btn-outline-primary btn-sm">
            <span className="icon icon-add-user"></span> Follow
          </button>*/}
        </div>
      </div>
    )
  }
}


function mapStateToProps({ posts }) {
  return { posts }; // { posts } == { posts: posts }
}

export default connect(null, { })(Profile);