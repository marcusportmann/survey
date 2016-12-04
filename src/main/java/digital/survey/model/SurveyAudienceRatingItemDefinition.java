///*
// * Copyright 2016 Marcus Portmann
// * All rights reserved.
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// */
//
//package digital.survey.model;
//
////~--- non-JDK imports --------------------------------------------------------
//
//import com.fasterxml.jackson.annotation.JsonProperty;
//import com.fasterxml.jackson.annotation.JsonPropertyOrder;
//
//import java.io.Serializable;
//import java.util.UUID;
//
////~--- JDK imports ------------------------------------------------------------
//
///**
// * The <code>SurveyAudienceRatingDefinition</code> class implements the Survey Audience Rating
// * Item Definition entity, which represents the definition for an audience rating item that forms
// * part of a survey definition.
// *
// * @author Marcus Portmann
// */
//@JsonPropertyOrder({ "id", "name", "groupDefinitionId", "ratingType" })
//public class SurveyAudienceRatingDefinition
//  implements Serializable
//{
//  /**
//   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience rating
//   * item definition.
//   */
//  @JsonProperty
//  private UUID id;
//
//  /**
//   * The name of the survey audience rating item definition.
//   */
//  @JsonProperty
//  private String name;
//
//  /**
//   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience this
//   * survey audience rating item definition is associated with.
//   */
//  @JsonProperty
//  private UUID audienceId;
//
//  /**
//   * The type of survey group rating item.
//   */
//  @JsonProperty
//  private SurveyGroupRatingType ratingType;
//
//  /**
//   * Constructs a new <code>SurveyDefinitionGroupRating</code>.
//   */
//  @SuppressWarnings("unused")
//  SurveyAudienceRatingDefinition() {}
//
//  /**
//   * Constructs a new <code>SurveyDefinitionGroupRating</code>.
//   *
//   * @param id                the Universally Unique Identifier (UUID) used to uniquely identify the
//   *                          survey group rating item definition
//   * @param name              the name of the survey group rating item definition
//   * @param groupDefinitionId the Universally Unique Identifier (UUID) used to uniquely identify the
//   *                          survey group definition this survey group rating item definition is
//   *                          associated with
//   * @param ratingType        the type of survey group rating item
//   */
//  public SurveyAudienceRatingDefinition(UUID id, String name, UUID groupDefinitionId,
//    SurveyGroupRatingType ratingType)
//  {
//    this.id = id;
//    this.name = name;
//    this.groupDefinitionId = groupDefinitionId;
//    this.ratingType = ratingType;
//  }
//
//  /**
//   * Indicates whether some other object is "equal to" this one.
//   *
//   * @param obj the reference object with which to compare
//   *
//   * @return <code>true</code> if this object is the same as the obj argument otherwise
//   *         <code>false</code>
//   */
//  @Override
//  public boolean equals(Object obj)
//  {
//    if (this == obj)
//    {
//      return true;
//    }
//
//    if (obj == null)
//    {
//      return false;
//    }
//
//    if (getClass() != obj.getClass())
//    {
//      return false;
//    }
//
//    SurveyAudienceRatingDefinition other = (SurveyAudienceRatingDefinition) obj;
//
//    return id.equals(other.id);
//  }
//
//  /**
//   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
//   * definition this survey group rating item definition is associated with.
//   *
//   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
//   *         definition this survey group rating item definition is associated with
//   */
//  public UUID getGroupDefinitionId()
//  {
//    return groupDefinitionId;
//  }
//
//  /**
//   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
//   * rating item definition.
//   *
//   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
//   *         rating item definition
//   */
//  public UUID getId()
//  {
//    return id;
//  }
//
//  /**
//   * Returns the name of the survey group rating item definition.
//   *
//   * @return the name of the survey group rating item definition
//   */
//  public String getName()
//  {
//    return name;
//  }
//
//  /**
//   * Returns the type of survey group rating item.
//   *
//   * @return the type of survey group rating item
//   */
//  public SurveyGroupRatingType getRatingType()
//  {
//    return ratingType;
//  }
//
//  /**
//   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey group
//   * definition this survey group rating item definition is associated with.
//   *
//   * @param groupDefinitionId the Universally Unique Identifier (UUID) used to uniquely identify the
//   *                          survey group definition this survey group rating item definition is
//   *                          associated with
//   */
//  public void setGroupDefinitionId(UUID groupDefinitionId)
//  {
//    this.groupDefinitionId = groupDefinitionId;
//  }
//
//  /**
//   * Set the name of the survey group rating item definition.
//   *
//   * @param name the name of the survey group rating item definition
//   */
//  public void setName(String name)
//  {
//    this.name = name;
//  }
//
//  /**
//   * Set the type of survey group rating item.
//   *
//   * @param ratingType the type of survey group rating item
//   */
//  public void setRatingType(SurveyGroupRatingType ratingType)
//  {
//    this.ratingType = ratingType;
//  }
//
//  /**
//   * Returns the String representation of the survey group rating item definition.
//   *
//   * @return the String representation of the survey group rating item definition
//   */
//  @Override
//  public String toString()
//  {
//    return String.format(
//      "SurveyDefinitionGroupRating {id=\"%s\", name=\"%s\", ratingType=\"%s\"}", getId(),
//      getName(), getRatingType().description());
//  }
//}

