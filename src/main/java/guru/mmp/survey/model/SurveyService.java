/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package guru.mmp.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Default;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyService</code> class provides the Survey Service implementation.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("JpaQlInspection")
@ApplicationScoped
@Default
public class SurveyService
  implements ISurveyService
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(SurveyService.class);

  /* Entity Manager */
  @PersistenceContext(unitName = "Application")
  private EntityManager entityManager;

  /**
   * Constructs a new <code>SurveyService</code>.
   */
  public SurveyService() {}

  /**
   * Retrieve the latest versions of the filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the latest versions of the filtered survey definitions for the organisation
   */
  public List<SurveyDefinition> getFilteredLatestSurveyDefinitionsForOrganisation(UUID id,
      String filter)
    throws SurveyServiceException
  {
    try
    {
      StringBuilder filterBuffer = new StringBuilder();

      filterBuffer.append("%");
      filterBuffer.append(filter.toUpperCase());
      filterBuffer.append("%");

      String sql = "SELECT sd FROM SurveyDefinition sd WHERE sd.version ="
          + " (SELECT MAX(sdInner.version) FROM SurveyDefinition sdInner WHERE sdInner.id = sd.id)"
          + " AND (UPPER(sd.name) LIKE :filter)";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      query.setParameter("filter", filterBuffer.toString());

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the filtered latest versions of the"
          + " survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the filtered survey audiences members for the survey audience
   */
  public List<SurveyAudienceMember> getFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      StringBuilder filterBuffer = new StringBuilder();

      filterBuffer.append("%");
      filterBuffer.append(filter.toUpperCase());
      filterBuffer.append("%");

      String sql = "SELECT sam FROM SurveyAudienceMember sam JOIN sam.audience sa"
          + " WHERE sa.id = :id AND ((UPPER(sam.firstName) LIKE :filter)"
          + " OR (UPPER(sam.lastName) LIKE :filter) OR (UPPER(sam.email) LIKE :filter))";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);
      query.setParameter("filter", filterBuffer.toString());

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audience members for the survey audience with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the filtered survey audiences for the organisation
   */
  public List<SurveyAudience> getFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      StringBuilder filterBuffer = new StringBuilder();

      filterBuffer.append("%");
      filterBuffer.append(filter.toUpperCase());
      filterBuffer.append("%");

      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.organisationId = :id"
          + " AND (UPPER(sa.name) LIKE :filter)";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);
      query.setParameter("filter", filterBuffer.toString());

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audiences for the organisation with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the latest versions of the survey definitions for the organisation
   */
  public List<SurveyDefinition> getLatestSurveyDefinitionsForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sd FROM SurveyDefinition sd WHERE sd.version ="
          + " (SELECT MAX(sdInner.version) FROM SurveyDefinition sdInner WHERE sdInner.id = sd.id)";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the latest versions of the survey"
          + " definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the latest version for the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition
   *
   * @return the latest version for the survey definition or <code>null</code> if the survey
   *         definition could not be found
   */
  public SurveyDefinition getLatestVersionForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sd FROM SurveyDefinition sd WHERE sd.id = :id"
          + " AND sd.version IN (SELECT MAX(sd.version) FROM SurveyDefinition sd WHERE sd.id = :id)";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      query.setParameter("id", id);

      List<SurveyDefinition> surveyDefinitions = query.getResultList();

      if (surveyDefinitions.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitions.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the latest version of the survey definition with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the latest version number for the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to identify the survey definition
   *
   * @return the latest version number for the survey definition or 0 if the survey definition
   *         could not be found
   */
  public int getLatestVersionNumberForSurveyDefinition(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT MAX(sd.version) FROM SurveyDefinition sd WHERE sd.id = :id";

      Query query = entityManager.createQuery(sql);

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the latest version number for the survey definition with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the survey audience members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audiences members for the survey audience
   */
  public List<SurveyAudienceMember> getMembersForSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql =
          "SELECT sam FROM SurveyAudienceMember sam JOIN sam.audience sa WHERE sa.id = :id";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audience members for the survey audience with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the number of latest versions of the filtered survey definitions for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey definitions
   *
   * @return the number of latest versions of the filtered survey definitions for the organisation
   */
  public int getNumberOfFilteredLatestSurveyDefinitionsForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      StringBuilder filterBuffer = new StringBuilder();

      filterBuffer.append("%");
      filterBuffer.append(filter.toUpperCase());
      filterBuffer.append("%");

      String sql = "SELECT COUNT(sd.id) FROM SurveyDefinition sd WHERE sd.version ="
          + " (SELECT MAX(sdInner.version) FROM SurveyDefinition sdInner WHERE sdInner.id = sd.id)"
          + " AND (UPPER(sd.name) LIKE :filter)";

      Query query = entityManager.createQuery(sql);

      query.setParameter("filter", filterBuffer.toString());

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the number of filtered latest versions"
          + " of the survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Returns the number of filtered survey audience members for the survey audience.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *               audience
   * @param filter the filter used to limit the matching survey audience members
   *
   * @return the number of filtered survey audience members for the survey audience
   */
  public int getNumberOfFilteredMembersForSurveyAudience(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      StringBuilder filterBuffer = new StringBuilder();

      filterBuffer.append("%");
      filterBuffer.append(filter.toUpperCase());
      filterBuffer.append("%");

      Query query = entityManager.createQuery(
          "SELECT COUNT(sam.id) FROM SurveyAudienceMember sam JOIN sam.audience sa"
          + " WHERE sa.id = :id AND ((UPPER(sam.firstName) LIKE :filter)"
          + " OR (UPPER(sam.lastName) LIKE :filter) OR (UPPER(sam.email) LIKE :filter))");

      query.setParameter("id", id);
      query.setParameter("filter", filterBuffer.toString());

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audience members for the survey audience with ID ("
          + id + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Returns the number of filtered survey audiences for the organisation.
   *
   * @param id     the Universally Unique Identifier (UUID) used to uniquely identify the
   *               organisation
   * @param filter the filter used to limit the matching survey audiences
   *
   * @return the number of filtered survey audiences for the organisation
   */
  public int getNumberOfFilteredSurveyAudiencesForOrganisation(UUID id, String filter)
    throws SurveyServiceException
  {
    try
    {
      StringBuilder filterBuffer = new StringBuilder();

      filterBuffer.append("%");
      filterBuffer.append(filter.toUpperCase());
      filterBuffer.append("%");

      Query query = entityManager.createQuery("SELECT COUNT(sa.id) FROM SurveyAudience sa"
          + " WHERE sa.organisationId = :id AND (UPPER(sa.name) LIKE :filter)");

      query.setParameter("id", id);
      query.setParameter("filter", filterBuffer.toString());

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audiences for the organisation with ID (" + id
          + ") matching the filter (" + filter + ")", e);
    }
  }

  /**
   * Retrieve the number of latest versions of the survey definitions for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of latest versions of the survey definitions for the organisation
   */
  public int getNumberOfLatestSurveyDefinitionsForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT COUNT(sd.id) FROM SurveyDefinition sd WHERE sd.version ="
          + " (SELECT MAX(sdInner.version) FROM SurveyDefinition sdInner WHERE sdInner.id = sd.id)";

      Query query = entityManager.createQuery(sql);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the number of latest versions of the"
          + " survey definitions for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Returns the number of members for the survey audience.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the number of members for the survey audience
   */
  public int getNumberOfMembersForSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sam.id) FROM SurveyAudienceMember sam"
          + " WHERE sam.audience.id = :id");

      query.setParameter("id", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of members for the survey audience with ID (" + id + ")",
          e);
    }
  }

  /**
   * Returns the number of survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the number of survey audiences for the organisation
   */
  public int getNumberOfSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      Query query = entityManager.createQuery("SELECT COUNT(sa.id) FROM SurveyAudience sa"
          + " WHERE sa.organisationId = :organisationId");

      query.setParameter("organisationId", id);

      return ((Number) query.getSingleResult()).intValue();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the number of survey audiences for the organisation with ID (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the survey audience identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience
   *
   * @return the survey audience identified by the specified ID or <code>null</code> if the survey
   *         audience could not be found
   */
  public SurveyAudience getSurveyAudience(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.id = :id";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);

      List<SurveyAudience> surveyAudiences = query.getResultList();

      if (surveyAudiences.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyAudiences.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey audience (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey audience member identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           audience member
   *
   * @return the survey audience member identified by the specified ID or <code>null</code> if the
   *         survey audience member could not be found
   */
  public SurveyAudienceMember getSurveyAudienceMember(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sam FROM SurveyAudienceMember sam WHERE sam.id = :id";

      TypedQuery<SurveyAudienceMember> query = entityManager.createQuery(sql,
          SurveyAudienceMember.class);

      query.setParameter("id", id);

      List<SurveyAudienceMember> surveyAudienceMembers = query.getResultList();

      if (surveyAudienceMembers.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyAudienceMembers.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey audience member (" + id
          + ")", e);
    }
  }

  /**
   * Retrieve the survey audiences for the organisation.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the organisation
   *
   * @return the survey audiences for the organisation
   */
  public List<SurveyAudience> getSurveyAudiencesForOrganisation(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sa FROM SurveyAudience sa WHERE sa.organisationId = :id";

      TypedQuery<SurveyAudience> query = entityManager.createQuery(sql, SurveyAudience.class);

      query.setParameter("id", id);

      return query.getResultList();
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException(
          "Failed to retrieve the survey audiences for the organisation with ID (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey definition identified by the specified ID and version.
   *
   * @param id      the Universally Unique Identifier (UUID) used, along with the version of the
   *                survey definition, to uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the survey definition identified by the specified ID and version or <code>null</code>
   *         if the survey definition could not be found
   */
  public SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT st FROM SurveyDefinition st WHERE st.id = :id AND st.version = :version";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(sql, SurveyDefinition.class);

      query.setParameter("id", id);
      query.setParameter("version", version);

      List<SurveyDefinition> surveyDefinitions = query.getResultList();

      if (surveyDefinitions.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitions.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey definition (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey instance identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey instance
   *
   * @return the survey instance identified by the specified ID or <code>null</code> if the survey
   *         instance could not be found
   */
  public SurveyInstance getSurveyInstance(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT si FROM SurveyInstance si WHERE si.id = :id";

      TypedQuery<SurveyInstance> query = entityManager.createQuery(sql, SurveyInstance.class);

      query.setParameter("id", id);

      List<SurveyInstance> surveyInstances = query.getResultList();

      if (surveyInstances.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyInstances.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey instance (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey request identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   *
   * @return the survey request identified by the specified ID or <code>null</code> if the survey
   *         request could not be found
   */
  public SurveyRequest getSurveyRequest(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyRequest sr WHERE sr.id = :id";

      TypedQuery<SurveyRequest> query = entityManager.createQuery(sql, SurveyRequest.class);

      query.setParameter("id", id);

      List<SurveyRequest> surveyRequests = query.getResultList();

      if (surveyRequests.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyRequests.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey request (" + id + ")", e);
    }
  }

  /**
   * Retrieve the survey response identified by the specified ID.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           response
   *
   * @return the survey response identified by the specified ID or <code>null</code> if the survey
   *         response could not be found
   */
  public SurveyResponse getSurveyResponse(UUID id)
    throws SurveyServiceException
  {
    try
    {
      String sql = "SELECT sr FROM SurveyResponse sr WHERE sr.id = :id";

      TypedQuery<SurveyResponse> query = entityManager.createQuery(sql, SurveyResponse.class);

      query.setParameter("id", id);

      List<SurveyResponse> surveyResponses = query.getResultList();

      if (surveyResponses.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyResponses.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey response (" + id + ")", e);
    }
  }

  /**
   * Save the survey audience.
   *
   * @param surveyAudience the survey audience
   *
   * @return the saved survey audience
   */
  @Transactional
  public SurveyAudience saveSurveyAudience(SurveyAudience surveyAudience)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyAudience))
      {
        surveyAudience = entityManager.merge(surveyAudience);
      }

      return surveyAudience;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey audience with ID ("
          + surveyAudience.getId() + ")", e);
    }
  }

  /**
   * Save the survey definition.
   *
   * @param surveyDefinition the survey definition
   *
   * @return the saved survey definition
   */
  @Transactional
  public SurveyDefinition saveSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException
  {
    try
    {
      // Check if a survey instance exists for the current version of the survey definition
      Query surveyInstanceExistsQuery = entityManager.createQuery(
          "SELECT COUNT(si.id) FROM SurveyInstance si JOIN si.definition sd"
          + " WHERE sd.id = :id AND sd.version = :version");

      surveyInstanceExistsQuery.setParameter("id", surveyDefinition.getId());
      surveyInstanceExistsQuery.setParameter("version", surveyDefinition.getVersion());

      boolean surveyInstanceExists =
          (((Number) surveyInstanceExistsQuery.getSingleResult()).intValue() > 0);

      // Duplicate the survey definition and increment the current version if required
      if (surveyInstanceExists)
      {
        surveyDefinition = surveyDefinition.duplicate();

        surveyDefinition.incrementVersion();
      }

      if (!entityManager.contains(surveyDefinition))
      {
        surveyDefinition = entityManager.merge(surveyDefinition);
      }

      return surveyDefinition;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey definition with ID ("
          + surveyDefinition.getId() + ")", e);
    }
  }

  /**
   * Save the survey instance.
   *
   * @param surveyInstance the survey instance
   *
   * @return the saved survey instance
   */
  @Transactional
  public SurveyInstance saveSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyInstance))
      {
        surveyInstance = entityManager.merge(surveyInstance);
      }

      return surveyInstance;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey instance with ID ("
          + surveyInstance.getId() + ")", e);
    }
  }

  /**
   * Save the survey response.
   *
   * @param surveyResponse the survey response
   *
   * @return the saved survey response
   */
  @Transactional
  public SurveyResponse saveSurveyResponse(SurveyResponse surveyResponse)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyResponse))
      {
        surveyResponse = entityManager.merge(surveyResponse);
      }

      return surveyResponse;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey response with ID ("
          + surveyResponse.getId() + ")", e);
    }
  }
}
